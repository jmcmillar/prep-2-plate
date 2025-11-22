# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Prep-2-Plate is a Rails 8 meal planning and recipe management application with:
- Recipe browsing and favorites
- Meal planning with calendar integration
- Shopping list generation from meal plans
- User-generated recipes with import functionality
- Admin dashboard for content management
- RESTful API for mobile/SPA clients

## Technology Stack

- **Rails**: 8.0.3 (Ruby 3.2.3)
- **Database**: PostgreSQL with multiple databases (primary, cache, queue, cable via Solid* adapters)
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS, ViewComponent
- **Background Jobs**: Solid Queue with Mission Control monitoring
- **Authentication**: Custom session-based with Bearer token support for API
- **Authorization**: Pundit policies
- **Testing**: Minitest with parallel execution

## Development Commands

### Setup
```bash
bin/setup                          # Initial setup (installs deps, creates db, seeds data)
```

### Server
```bash
bin/dev                            # Start development server with Tailwind watch (uses Procfile.dev)
bin/rails server                   # Start Rails server only
```

### Database
```bash
bin/rails db:create                # Create databases
bin/rails db:migrate               # Run pending migrations
bin/rails db:reset                 # Drop, create, migrate, and seed
bin/rails db:rollback              # Rollback last migration
bin/rails db:rollback STEP=N       # Rollback N migrations
```

### Testing
```bash
bin/rails test                     # Run all tests (runs in parallel)
bin/rails test test/models/user_test.rb              # Run specific test file
bin/rails test test/models/user_test.rb:15           # Run test at specific line
```

### Code Quality
```bash
bin/rubocop                        # Run Ruby linter (Rails Omakase style)
bin/rubocop -a                     # Auto-fix violations
bin/brakeman                       # Run security scanner
```

### Background Jobs
```bash
bin/jobs                           # Start Solid Queue worker
# Visit http://localhost:3000/jobs for Mission Control dashboard
```

### Assets
```bash
bin/rails tailwindcss:build        # Build Tailwind CSS
bin/rails tailwindcss:watch        # Watch and rebuild CSS
bin/importmap                      # Manage JavaScript imports
```

### Session Management
```bash
bin/rails sessions:cleanup         # Remove expired sessions
bin/rails sessions:stats           # Show session statistics
```

## Architecture Patterns

### Facade Pattern (Presentation Layer)
Controllers delegate to Facades for view logic. Facades inherit from `BaseFacade` and provide:
- View component configuration
- Data formatting for templates
- Layout and navigation state

Example: `app/facades/recipes/index_facade.rb` handles recipe listing presentation.

### ViewComponent Architecture
UI components in `app/components/` are Ruby classes with templates:
- `ApplicationComponent` base class
- Typed data structures (using Ruby `Data` class)
- Reusable form components in `app/components/form/`
- Table components with sorting/filtering in `app/components/table/`

### Service Objects
Simple service classes in `app/services/` for business logic:
- `BuildRecipeIngredients` - Parses and creates recipe ingredients
- `FlashService` - Manages flash messages

### API Structure
API controllers in `app/controllers/api/` and facades in `app/facades/api/`:
- Separate routes in `config/routes/api.rb` under `/api` namespace
- Bearer token authentication required
- JSON responses
- API authentication via `Api::AuthController`

### Multi-Database Setup (Solid Stack)
Four PostgreSQL databases in production:
- **primary**: Application data
- **cache**: Solid Cache
- **queue**: Solid Queue (background jobs)
- **cable**: Solid Cable (WebSockets)

In development, uses single database with environment variable configuration.

### Authentication System
Custom secure session-based authentication (see `SECURITY_IMPROVEMENTS.md`):
- Token-based sessions with 2-week expiration
- Rate limiting on authentication endpoints (5 attempts per 15 minutes)
- Session activity tracking
- Comprehensive security logging (grep for `AUTH_EVENT`)
- Bearer token support for API clients

Key files:
- `app/controllers/concerns/authentication.rb`
- `app/controllers/concerns/rate_limitable.rb`
- `app/models/session.rb`
- `docs/AUTHENTICATION_GUIDE.md`

### Authorization
Pundit policies in `app/policies/`:
- `ApplicationPolicy` base class
- Scoped policies in `app/policies/base/`
- Controllers use `authorize` method

### Data Structures
Custom data objects in `app/data_structures/` for typed, immutable domain objects.

### Decorators
View decorators in `app/decorators/` enhance models with presentation logic.

## Database Views
Uses `scenic` gem for database views (SQL definitions in `db/views/`).

## Image Processing
Active Storage with AWS S3 in production (`aws-sdk-s3` gem). Image transformations use `image_processing` gem.

## Recipe Import
`RecipeImport` model with URL-based import functionality in `app/controllers/user_recipe_imports_controller.rb`.

## AI Integration
Uses `ruby-openai` gem for recipe-related AI features.

## Email
Mailgun for production (`mailgun-ruby` gem). In development, use Letter Opener Web at http://localhost:3000/letter_opener.

## Background Jobs & Scheduling
- Solid Queue for job processing
- Recurring jobs configured in `config/recurring.yml`
- Monitor jobs at http://localhost:3000/jobs (Mission Control)
- Example: `SessionCleanupJob` for expired session cleanup

## Testing Considerations
- Fixtures in `test/fixtures/`
- Tests run in parallel by default
- JSON schema matchers available (`json_matchers` gem)
- SimpleCov for coverage
- System tests with Selenium WebDriver

## Important Conventions

### Controller Organization
- Public controllers: Recipe browsing, landing pages
- Authenticated controllers: Inherit from `AuthenticatedController` for logged-in users
- Admin controllers: In `app/controllers/admin/` namespace
- API controllers: In `app/controllers/api/` namespace (inherit from ActionController::API)

### Model Associations
- `Recipe`: Can be user-generated (`UserRecipe`) or admin-curated
- `MealPlan`: User's planned meals
- `ShoppingList`: Generated from meal plans
- User has many: favorites, meal plans, shopping lists, user recipes

### Route Organization
- Main routes: `config/routes.rb`
- Admin routes: `config/routes/admin.rb` (drawn via `draw "admin"`)
- API routes: `config/routes/api.rb` (drawn via `draw "api"`)

## Security Notes
- Sessions use cryptographically secure tokens (32 bytes, 256 bits entropy)
- Rate limiting prevents brute force attacks
- All authentication events are logged with `AUTH_EVENT` prefix
- CSRF protection via `same_site: :lax` cookies
- Production cookies use `secure: true` (HTTPS only)
- See `SECURITY_IMPROVEMENTS.md` for security audit details

## Development Workflow
1. Create feature branch from `master`
2. Run tests after changes
3. Ensure Rubocop passes
4. Run Brakeman for security checks
5. Test authentication flows if modifying auth code
6. Check logs for authentication events during testing
