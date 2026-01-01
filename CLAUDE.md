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
- **Database**: PostgreSQL with multiple databases (primary, cache, queue, cable via Solid\* adapters)
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS, ViewComponent
- **Background Jobs**: Solid Queue with Mission Control monitoring
- **Authentication**: Dual system - Devise (web) + Custom Session model (API)
- **Authorization**: Pundit policies with deny-by-default
- **Testing**: Minitest with parallel execution

## Directory Structure

### Standard Rails Directories

- `app/controllers/` - HTTP request handlers (keep extremely thin: 3-10 lines per action)
- `app/models/` - Data persistence and validations ONLY (no business logic)
- `app/views/` - ERB templates (delegate to facades for data)
- `app/jobs/` - Background job processing
- `config/` - Application configuration

### Custom Directories (Non-Standard Rails)

- **`app/facades/`** - Presentation layer (replaces "fat models, skinny controllers")
  - Controllers delegate ALL view logic to facades
  - Facades prepare data for templates, configure components, manage layout state
- **`app/components/`** - ViewComponent UI components
  - Organized by domain: `form/`, `table/`, etc.
  - Each component has Ruby class + ERB template
- **`app/data_structures/`** - Typed, immutable domain objects
  - Uses Ruby `Struct` for type safety
  - Examples: `MenuItemData`, `ColumnData`, `ButtonLinkData`
- **`app/decorators/`** - View decorators using `SimpleDelegator`
  - Enhance models with presentation logic
  - NOT using Draper gem
- **`app/lib/`** - Domain-specific business logic and utilities
  - Menu and navigation builders
  - Recipe import parsers
  - Ingredient parsing utilities
  - Quantity conversion classes
- **`app/policies/`** - Pundit authorization policies
  - Base policies in `app/policies/base/`
- **`app/services/`** - Service objects for complex business logic
  - Single-responsibility, reusable operations
- **`app/builders/`** - Custom form builders
- **`app/validators/`** - Custom validators

## Development Commands

### Docker Environment

**Note:** When running in Docker, prefix all `bin/rails` commands with `docker compose run --rm web`:

```bash
# Examples:
docker compose run --rm web bin/rails db:migrate
docker compose run --rm web bin/rails test
docker compose run --rm web bin/rails console
```

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

## Code Quality & Design Principles

When writing or modifying code, prioritize clean code conventions and SOLID principles:

### Clean Code Conventions

- **Meaningful Names**: Use descriptive, intention-revealing names for classes, methods, and variables
- **Single Responsibility**: Each method should do one thing and do it well
- **DRY (Don't Repeat Yourself)**: Extract repeated code into reusable methods or classes
- **Small Methods**: Keep methods short and focused (generally under 10 lines)
- **Avoid Deep Nesting**: Prefer guard clauses and early returns over nested conditionals
- **Comments**: Write self-documenting code; use comments only when necessary to explain "why", not "what"

### SOLID Principles

- **Single Responsibility Principle**: A class should have only one reason to change
  - Controllers handle HTTP requests/responses ONLY
  - Facades handle presentation logic
  - Services handle business logic
  - Models handle data persistence and validations ONLY
  - Jobs handle background processing
- **Open/Closed Principle**: Classes should be open for extension but closed for modification
  - Use inheritance and composition over modifying existing code
  - Leverage Rails concerns for shared behavior
- **Liskov Substitution Principle**: Subclasses should be substitutable for their base classes
  - Ensure inherited classes don't break parent class contracts
- **Interface Segregation Principle**: Prefer small, focused interfaces over large ones
  - Keep service objects focused on a single operation
  - Use multiple small concerns over one large concern
- **Dependency Inversion Principle**: Depend on abstractions, not concretions
  - Inject dependencies rather than hard-coding them
  - Use dependency injection in service objects and jobs

### Practical Application

- **Keep models lean**: Use service objects, jobs, or concerns for complex business logic
- **Fat models, skinny controllers** is outdated: Extract business logic to service objects
- **Controllers are extremely thin**: 3-10 lines per action (instantiate facade, render/redirect)
- **One level of abstraction per method**: Don't mix high-level and low-level operations
- **Prefer composition over inheritance**: Use modules and dependency injection
- **Write testable code**: If it's hard to test, it's probably not well-designed

## Critical Architectural Rules

**NEVER:**

- Add business logic methods to models (use services or jobs)
- Add presentation logic to models (use facades or decorators)
- Make controllers "smart" (delegate to facades)
- Use decimals for recipe quantities (use fractional numerator/denominator)
- Modify existing base classes without understanding impact

**ALWAYS:**

- Delegate view logic from controllers to facades
- Use service objects for complex business operations
- Use decorators for presentation enhancements
- Check authorization in facade initializers (not controllers)
- Use `CollectionBuilder` for pagination and search
- Log authentication events with `AUTH_EVENT:` prefix

## Architecture Patterns

### Facade Pattern (Presentation Layer)

**Core Concept**: Controllers delegate to Facades for ALL view-related logic.

#### BaseFacade (`app/facades/base_facade.rb`)

Base class for all facades:

- **Attributes**: `@user`, `@params`, `@strong_params`, `@session`
- **Layout methods**: `layout`, `menu`, `active_key`, `nav_resource`
- **Component helpers**: `sign_in_link`, `sign_out_link`, `shopping_list_link`
- **Delegation**: `respond_to_missing?` delegates to resource for convenience

#### Facade Hierarchy

**Base::Admin::IndexFacade** - Admin index pages

- Authorization check in initialize: `raise Pundit::NotAuthorizedError unless authorized?`
- Uses `CollectionBuilder` for pagination/search
- Methods: `headers`, `rows`, `pagy`, `header_actions`, `new_action_data`
- Default pagination: 25 items per page

**Base::Admin::ShowFacade** - Admin show pages

- Authorization check in initialize
- Methods: `header_actions`, `edit_action_data`

**Base::Authenticated::IndexFacade** - User index pages

- Similar to Admin::IndexFacade but for authenticated users
- Uses `Base::AuthenticatedPolicy` for authorization

#### ResourceFacade Pattern

Separate facade for individual records:

- Wraps single record for presentation
- Class methods: `self.headers`, `self.to_row(facade)` for table rendering
- Instance methods: presentation-specific data formatting
- Example: `app/facades/admin/recipes/resource_facade.rb`

#### Facade Naming Convention

- Pattern: `[Namespace]::[Resource]::[Action]Facade`
- Examples:
  - `Recipes::IndexFacade` - Public recipe listing
  - `Admin::Recipes::EditFacade` - Admin recipe editing
  - `Api::Recipes::ShowFacade` - API recipe detail

#### Facade Organization

- `/app/facades/` - Public/authenticated facades
- `/app/facades/admin/` - Admin facades
- `/app/facades/api/` - API facades (return data for JSON)
- `/app/facades/base/` - Base classes for inheritance

#### Controller-Facade Contract

Controllers are EXTREMELY thin (3-10 lines):

```ruby
# Good example
def index
  @facade = Recipes::IndexFacade.new(Current.user, params)
end

def show
  @facade = Recipes::ShowFacade.new(Current.user, params)
end
```

Views access data via `@facade`:

```erb
<%= @facade.title %>
<%= render @facade.recipe_component %>
```

### ViewComponent Architecture

#### ApplicationComponent (`app/components/application_component.rb`)

Base class for all components:

- Inherits from `ViewComponent::Base`
- Helper: `extract_html_from_options(options, key_list)` for HTML attribute extraction
- Constant: `HTML_OPTION_KEYS = %i[class data aria style id]`

#### Component Organization

**Form Components** (`app/components/form/`)

- `Form::LabelComponent` - Form labels
- `Form::CheckboxGroupTagsComponent` - Checkbox groups

**Table Components** (`app/components/table/`)

- `Table::RowComponent` - Table rows with striping
- `Table::DataComponent` - Table cells
- `Table::DefaultHeaderComponent` - Standard headers
- `Table::SortHeaderComponent` - Sortable headers with icons
- `Table::ActionComponent` - Action buttons/links
- `Table::IconActionsComponent` - Icon-based actions
- `Table::HeaderComponent` - Generic header wrapper

**UI Components** (`app/components/`)

- `ButtonLinkComponent` - Links styled as buttons with icons
- `IconComponent` - Font Awesome icon wrapper
- `IconLinkComponent` - Icon + text links
- `SearchFormComponent` - Search form with Ransack integration
- `FilterComponent` - Filter dropdowns
- `TableComponent` - Main table wrapper
- `FlashComponent` - Flash message display
- `BreadcrumbComponent` - Breadcrumb navigation
- `ModalButtonComponent` - Modal trigger buttons
- `EmptyComponent` - Renders nothing (for conditional rendering)
- `ToggleFormComponent` - Toggle switches
- `HeaderBarComponent` - Page headers
- `ContainerComponent` - Layout container
- `SectionCardComponent` - Card sections
- `BackgroundImageContainerComponent` - Hero sections with background images

#### Typed Props Pattern

Components use inline `Data = Struct.new(...)` for type safety:

```ruby
class ButtonLinkComponent < ApplicationComponent
  Data = Struct.new(:label, :path, :icon, :scheme, :options) do
    def initialize(*)
      super
      self.scheme ||= :primary
      self.options ||= {}
    end
  end

  def initialize(button_link_data:)
    @data = button_link_data
  end
end
```

#### Collection Rendering

Use `with_collection_parameter` for rendering collections:

```ruby
class ItemComponent < ApplicationComponent
  with_collection_parameter :item_data

  def initialize(item_data:)
    @item = item_data
  end
end
```

### Data Structures (Typed Domain Objects)

Located in `app/data_structures/`, these provide type safety without external gems:

**Core Data Objects (using Ruby Struct)**:

- `ColumnData` - Table column configuration
- `MenuItemData` - Navigation menu items
- `ButtonLinkSchemeData` - Button styling schemes
- `ActionRowData` - Action row configuration
- `BackgroundImageData` - Hero image data
- `RecipeData` - Recipe presentation data
- `TurboData` - Turbo Frame configuration

**Components subdirectory** (`app/data_structures/components/`):

- `Components::ButtonLinkData` - Button link data with keyword_init

**Pattern**:

- Immutable, typed data objects
- Used to pass data between layers
- Instantiated with bracket syntax: `Data[value1, value2]` or `.new`
- Prefer Structs over Hashes for type safety

### Decorator Pattern

#### BaseDecorator (`app/decorators/base_decorator.rb`)

Uses `SimpleDelegator` (NOT Draper gem):

- **Class methods**:
  - `decorate(object)` - Wraps single object
  - `decorate_collection(collection)` - Wraps collection
- **Instance methods**:
  - `original_object` - Returns wrapped object
  - `source_object` - Unwraps nested decorators

#### Common Decorators

**ImageDecorator** - Handles non-persisted images gracefully

- Prevents errors when image not attached

**IngredientFullNameDecorator** - Formats ingredient display

- Methods: `full_name`, `formatted_quantity`, `quantity`, `pluralized_measurement_unit`
- Handles whole numbers, fractions, and mixed numbers
- Example output: "2 1/2 cups flour (sifted)"

**MealPlanIngredient::NameDecorator** - Formats aggregated ingredients

- Used for shopping lists

#### Usage Pattern

```ruby
decorated_ingredients = IngredientFullNameDecorator.decorate_collection(recipe.recipe_ingredients)
```

### Service Objects

#### Service Module (`app/services/service.rb`)

Concern providing class-level `call(...)` method:

- Pattern: `ServiceName.call(args)` → `new(args).call`
- Used for single-responsibility business logic

#### Service Objects

**BuildRecipeIngredients** - Parses and creates recipe ingredients

- Uses `AttributeData` struct internally
- Handles fractional quantities via `RecipeUtils::ParseQuantity`

**FlashService** - Renders flash messages as ViewComponents

- Maps flash types to CSS schemes and icons
- Returns rendered component HTML

**UserRecipes::ProcessParams** - Processes nested form params

- Converts quantity strings to numerator/denominator using `QuantityFactory`

#### Service Pattern

- Keep models lean - NO complex business logic in models
- Services are Plain Old Ruby Objects (POROs)
- Each service does ONE thing
- Called from controllers, jobs, or other services
- Include `Service` module for `.call` class method

### Library Code Organization (`app/lib/`)

**IMPORTANT**: Significant business logic lives here. This is NOT a dumping ground - it's organized domain logic.

#### Menu and Navigation

- **`MenuData`** - Static menu definitions
  - Inner classes: `IconMap`, `Format`
  - Methods: `admin_menu`, `admin_user_menu`, `account_setting_menu`, `main_menu`
  - Icon mapping for Font Awesome icons
  - CSS format patterns for active/inactive states
- **`Layout`** - Builds navigation from MenuData
- **`BuildNavItemCollectionService`** - Constructs navigation collections

#### Collection Handling

- **`CollectionBuilder`** - Wraps ActiveRecord relations for pagination and search
  - Integrates Ransack for searching
  - Integrates Pagy for pagination
  - Returns array of decorated/facade objects
  - Usage: `CollectionBuilder.new(relation, params).build`

#### Recipe Import Parsers (`app/lib/import/parsers/`)

- **`BaseParser`** - Abstract parser with NullObject pattern
  - Methods: `can_parse?`, `parse`
  - Template method pattern for recipe attributes
  - `parse_duration` handles ISO8601 format
- **Concrete parsers**:
  - `JsonLdParser` - Schema.org JSON-LD
  - `SchemaOrgRecipeParser` - Microdata
  - `HrecipeParser` - Microformat
  - `DataVocabularyRecipeParser`
  - `NullRecipeParser` - Fallback (returns nil)
- **`ParserSelector`** - Chooses appropriate parser based on HTML
- **`CanonicalUrlParser`** - Extracts canonical URLs from HTML

#### Recipe Parsing and Utilities

- **`Parser`** module - Recipe import entry point
  - Defines `RECIPE_ATTRIBUTES` and `NUTRITION_ATTRIBUTES`
  - `RecipeData = Struct.new(*RECIPE_ATTRIBUTES)`
  - `parse(html)` - main entry point
- **`ParseIngredient`** - Parses ingredient strings into structured data
  - Converts unicode fractions to ASCII
  - Extracts: quantity, measurement_unit_id, ingredient_name, notes

**RecipeUtils** module (`app/lib/recipe_utils/`):

- `ParseQuantity` - Converts strings to Rational numbers
- `ParseUnit` - Identifies measurement units from strings
- `ParseIngredientName` - Extracts ingredient name
- `ParseNotes` - Extracts notes (parenthesized text)
- `UnicodeFractions` - Converts unicode fractions to ASCII (½ → 1/2)
- `Calendar` / `CalendarEvent` - iCal generation for meal plans

#### Quantity Conversions (`app/lib/conversions/`)

- `WholeToFraction` - Converts whole numbers to fractions
- `MixedToImproperFraction` - Converts mixed numbers to improper fractions
- `DecimalToFraction` - Converts decimals to fractions

#### Link Builders (`app/lib/link/`)

- `Link::Action` - Generates action links
- `Link::Edit` - Edit action links
- `Link::Destroy` - Destroy action links with confirmation
- `Link::RowActions` - Combines multiple actions for table rows

#### Other Utilities

- **`QuantityFactory`** - Creates Rational from string input
- **`QuantityMultiplierDecorator`** - Scales quantities for serving size adjustments
- **`UserRecipeImportParser`** - Parses user recipe imports
- **`UserSerializer`** - Serializes user data for API responses

### Controller Architecture

#### Controller Hierarchy

```
ApplicationController (base for web requests)
├── PublicController (no authentication required)
└── AuthenticatedController (Devise authentication required)
    ├── Admin::* controllers (admin-only, inherit from AdminController)
    └── User-specific controllers (meal plans, shopping lists, etc.)

ActionController::API (base for API requests)
└── Api::BaseController (Bearer token authentication required)
    └── Api::* controllers (recipes, auth, shopping lists, etc.)
```

#### ApplicationController

- Includes: `DestroyFlash`, `Pagy::Frontend`
- `before_action :set_current_user` - Sets `Current.user` from Devise
- Pundit error handling: `rescue_from Pundit::NotAuthorizedError`
- Devise configuration for permitted params

#### AuthenticatedController

- `before_action :authenticate_user!` (Devise)
- `allow_browser versions: :modern` (Rails 8 feature)
- Base for all authenticated web controllers

#### Api::BaseController

- Inherits from `ActionController::API`
- Includes `Api::TokenAuthentication` concern
- `before_action :set_default_format` - Forces JSON for `*/*` or HTML requests
- Error handling:
  - `ActionController::ParameterMissing` → 400 Bad Request
  - `ActiveRecord::RecordNotFound` → 404 Not Found
  - `Pundit::NotAuthorizedError` → 403 Forbidden

#### Controller Concerns

**DestroyFlash** - Automatic flash messages after destroy actions

- `set_destroy_flash_for(record)` checks if destroyed, sets appropriate flash
- Included in ApplicationController

**RateLimitable** - Rate limiting for authentication endpoints

- `check_rate_limit(key:, limit:, period:)` uses Rails.cache
- Raises `RateLimitExceeded` if limit exceeded
- Logs warnings with IP address
- Returns 429 Too Many Requests status code

**Api::TokenAuthentication** - Bearer token authentication

- `authenticate_with_bearer_token` - Parses `Authorization: Bearer <token>` header
- `start_new_session_for(user)` - Creates API session
- `terminate_session` - Destroys API session
- **Extensive logging**: All auth events logged with `AUTH_EVENT:` prefix
- Suspicious activity detection (IP address or user agent changes)

#### Current Model (Request-Scoped Data)

`Current` model extends `ActiveSupport::CurrentAttributes`:

- **Attributes**: `:session` (API auth), `:user` (web auth via Devise)
- Usage: `Current.user` to access current user anywhere in request cycle
- Automatically reset between requests

#### Controller Pattern (Critical)

Controllers must be EXTREMELY thin (3-10 lines per action):

```ruby
# GOOD - Thin controller
class RecipesController < ApplicationController
  def index
    @facade = Recipes::IndexFacade.new(Current.user, params)
  end

  def show
    @facade = Recipes::ShowFacade.new(Current.user, params)
  end
end

# BAD - Fat controller (don't do this)
class RecipesController < ApplicationController
  def index
    @recipes = Recipe.all
    @featured = Recipe.featured
    # ... lots of view logic ...
    # This should ALL be in a facade!
  end
end
```

### Authorization (Pundit)

#### ApplicationPolicy (`app/policies/application_policy.rb`)

Base policy with deny-by-default approach:

- Requires authenticated user: `raise Pundit::NotAuthorizedError unless user`
- All methods return `false` by default (must explicitly allow)
- Methods: `index?`, `show?`, `create?`, `new?`, `update?`, `edit?`, `destroy?`
- Includes `Scope` inner class for scoping collections
- Delegation: `new?` → `create?`, `edit?` → `update?`

#### Base Policies

**Base::AdminPolicy** - Admin-only access

- All methods check `user.admin?`
- Scope returns `scope.all` if admin, else `scope.none`
- Used for admin namespace controllers

**Base::AuthenticatedPolicy** - Authenticated user access

- All methods check `user.persisted?`
- Scope returns `scope.all` if persisted, else `scope.none`
- Used for user-facing authenticated controllers

**Base::UnauthenticatedPolicy** - Public access (allow all)

- All methods return `true`
- Used for public-facing controllers

#### Authorization Pattern

**Critical**: Authorization is checked in **facade initializers**, NOT controllers!

```ruby
# In facade
class Admin::Recipes::IndexFacade < Base::Admin::IndexFacade
  def initialize(user, params)
    super
    raise Pundit::NotAuthorizedError unless authorized?
  end

  private

  def authorized?
    Base::AdminPolicy.new(user, nil).index?
  end
end
```

ApplicationController rescues:

```ruby
rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
```

### Model Architecture

#### Core Domain Models

**User Model**

- **Authentication**: Uses Devise for web authentication
  - Modules: `:database_authenticatable`, `:registerable`, `:recoverable`, `:rememberable`, `:validatable`, `:confirmable`, `:lockable`, `:timeoutable`, `:trackable`
- **Separate API Authentication**: Custom `Session` model for Bearer tokens (see below)
- **Associations**: `has_many :sessions, :user_recipes, :recipe_favorites, :user_meal_plans, :meal_plans, :shopping_lists, :shopping_list_items`
- **Attachments**: `has_one_attached :profile_image` (Active Storage)
- **Normalization**: Email stripped and lowercased

**Session Model** - Custom API Authentication (NOT Devise sessions!)

- **Purpose**: Bearer token authentication for API clients
- **Constants**:
  - `SESSION_LIFETIME = 2.weeks`
  - `TOKEN_LENGTH = 32` (bytes)
- **Token Generation**: `SecureRandom.urlsafe_base64(32)` → 256 bits entropy
- **Methods**:
  - `active?` - Not expired
  - `expired?` - Past expiration time
  - `touch_last_used!` - Updates last_used_at timestamp
  - `extend_expiration!` - Extends expiration by SESSION_LIFETIME
  - `suspicious_activity?` - Detects IP/user agent changes
- **Class Methods**:
  - `find_by_token(token)` - Finds session and touches last_used

**Recipe Model**

- Central model supporting both admin-curated and user-generated recipes
- **Rich Text**: `has_rich_text :description` (Action Text)
- **Attachments**: `has_one_attached :image` (Active Storage)
- **Associations**: `recipe_ingredients`, `recipe_instructions`, `meal_types`, `recipe_categories`, `recipe_favorites`
- **Optional**: `belongs_to :recipe_import` (for imported recipes)
- **User Recipes**: `has_one :user_recipe` to distinguish user-generated
- **Scopes**: `imported`, `featured`, `filtered_by_recipe_categories`, `filtered_by_meal_types`, `filtered_by_duration`
- **Class Methods**: `difficulty_levels` returns hash of levels

**RecipeIngredient Model** - IMPORTANT: Uses Fractional Quantities!

- **Fractional Storage**: Uses `numerator` and `denominator` fields (NOT decimals!)
  - Reason: Precise representation of recipe quantities (1/3, 1/2, etc.)
- **Virtual Attribute**: `ingredient_name=` for form handling
- **Callbacks**: `before_validation :find_or_create_ingredient` - Auto-creates ingredients
- **Methods**:
  - `quantity` - Returns Rational number
  - `quantity_value` - Returns formatted string (whole, fraction, or mixed number)
- **Associations**: `belongs_to :recipe`, `belongs_to :ingredient`, `belongs_to :measurement_unit`

**Ingredient Model**

- **Validation**: `uniqueness: { case_sensitive: false }`
- **Normalization**: `before_save :downcase_fields` - Normalizes names
- **Associations**: `belongs_to :ingredient_category, optional: true`
- **Deletion Protection**: `has_many :recipe_ingredients, dependent: :restrict_with_error`

**UserRecipe Model**

- **Purpose**: Join model linking users to their created recipes
- **Associations**: `belongs_to :user`, `belongs_to :recipe`
- **Nested Attributes**: `accepts_nested_attributes_for :recipe`
- **Heavy Delegation**: Delegates `name`, `image`, `description`, `serving_size`, `duration_minutes`, `difficulty_level`, `recipe_ingredients`, `recipe_instructions` to `:recipe`

**RecipeImport Model**

- Tracks imported recipes from external URLs
- **Custom Validator**: `:https_url` (in `app/validators/https_url_validator.rb`)
- **Associations**: `has_many :recipes`

**MealPlan Model**

- Admin-curated meal plans
- **Associations**: `has_many :meal_plan_recipes, :recipes, :ingredients, :recipe_ingredients`
- **Scopes**: `featured`

**MealPlanIngredient Model** - DATABASE VIEW (Not a table!)

- **Type**: Database view (extends `DatabaseView` base class)
- **SQL**: Defined in `db/views/meal_plan_ingredients_v01.sql`
- **Purpose**: Aggregates ingredients across all recipes in meal plan with formatted quantities
- **Implementation**: Complex SQL with CTEs for fraction formatting
- **Read-Only**: `readonly? → true`

**ShoppingList Model**

- User-specific shopping lists generated from meal plans
- **Associations**: `belongs_to :user`, `has_many :shopping_list_items, dependent: :destroy`
- **Scopes**: `for_user(user)`, `current`, `recent`

#### Key Model Conventions

- All models inherit from `ApplicationRecord`
- **Ransack integration**: Most models define `ransackable_attributes` and `ransackable_associations`
- **Nested attributes**: Extensive use of `accepts_nested_attributes_for` for complex forms
- **Deletion behavior**: Prefer explicit `dependent: :destroy` or `dependent: :restrict_with_error`
- **Normalization callbacks**: `before_save :downcase_fields` pattern for Ingredient and MeasurementUnit
- **NO business logic in models** - Use services, jobs, or lib classes

#### DatabaseView Base Class

For Scenic gem database views:

- `self.abstract_class = true`
- `def readonly?; true; end`
- Subclasses represent SQL views (not tables)
- Example: `MealPlanIngredient < DatabaseView`

### Database Architecture

#### Multi-Database Setup (Solid Stack)

Four separate PostgreSQL databases in production:

- **primary** (`db/schema.rb`) - Application data (users, recipes, etc.)
- **cache** (`db/cache_schema.rb`) - Solid Cache
- **queue** (`db/queue_schema.rb`) - Solid Queue (background jobs)
- **cable** (`db/cable_schema.rb`) - Solid Cable (WebSockets)

In development: Single database with environment variable configuration.

#### Database Views (Scenic Gem)

SQL views in `db/views/`:

- `meal_plan_ingredients_v01.sql` - Aggregates ingredients across meal plan recipes
- Complex SQL with CTEs for fraction formatting using GCD calculations
- Versioned via migrations (e.g., `_v01`, `_v02`)

#### Migrations

- Standard Rails migrations in `db/migrate/`
- Follow Rails naming conventions
- Scenic views have separate migration files

### Background Jobs & Scheduling

#### ApplicationJob (`app/jobs/application_job.rb`)

- Base class: `< ActiveJob::Base`
- No custom retry/discard configuration (uses Rails defaults)

#### Job Classes

**SessionCleanupJob** - Removes expired API sessions

- Queue: `:default`
- Calls `Session.cleanup_expired`
- Scheduled: Every 3 days at 2am (prod), daily (dev)

**CategorizeIngredientsJob** - AI-powered ingredient categorization

- **AI Integration**: Uses Claude API (Anthropic) via direct HTTP calls
- **Model**: `claude-sonnet-4-20250514`
- **Batch size**: 75 ingredients at a time
- **Categories**: Fresh Produce, Proteins, Dairy & Eggs, Grains & Bread, Canned & Jarred, Frozen Foods, Spices & Seasonings, Condiments & Sauces, Baking, Beverages, Snacks, Other
- **Error handling**: Graceful - continues to next batch on failure
- **Scheduled**: Daily at 1am

**OrphanedIngredientCleanupJob** - Removes unused ingredients

- Finds ingredients with no associated recipe_ingredients
- Uses `left_joins` and `where(recipe_ingredients: { id: nil })`
- Scheduled: Daily at 3am

**OrphanedRecipeImportCleanupJob** - Removes unused recipe imports

- Scheduled: Daily at 4am

#### Recurring Jobs

Configured in `config/recurring.yml`:

- Solid Queue built-in cleanup: Every hour at minute 12
- Session cleanup: Every 3 days at 2am (prod), daily (dev)
- Orphaned ingredient cleanup: Daily at 3am
- Orphaned recipe import cleanup: Daily at 4am
- Categorize ingredients: Daily at 1am

#### Job Infrastructure

- **Queue**: Solid Queue (database-backed)
- **Monitoring**: Mission Control Jobs at http://localhost:3000/jobs
- **Authentication**: `MissionControl::Jobs.base_controller_class = "AuthenticatedController"`

### API Structure

#### API Controllers

Located in `app/controllers/api/`:

- Inherit from `Api::BaseController` (ActionController::API)
- Bearer token authentication required (via `Api::TokenAuthentication` concern)
- Return JSON responses
- Separate facades in `app/facades/api/`

#### API Routes

Configured in `config/routes/api.rb`:

- Namespace: `api`
- Authentication endpoints:
  - `POST /api/auth/sign_in` - Login, returns Bearer token
  - `POST /api/auth/sign_up` - Registration
  - `DELETE /api/auth/sign_out` - Logout
- Resource endpoints: recipes, shopping_lists, meal_plans, recipe_categories, etc.

#### API Authentication Flow

1. Client sends credentials to `/api/auth/sign_in`
2. Server validates, creates Session record, returns token
3. Client includes token in subsequent requests: `Authorization: Bearer <token>`
4. `Api::TokenAuthentication` validates token on each request
5. Session tracked: IP address, user agent, last_used_at
6. Suspicious activity detected (IP/user agent changes) and logged

### JavaScript (Stimulus Controllers)

Located in `app/javascript/controllers/`:

**Core Controllers**:

- `application_controller.js` - Base controller
- `modal_controller.js` - Modal dialogs
- `dropdown_controller.js` - Dropdown menus
- `navbar_controller.js` - Mobile navigation
- `tabs_controller.js` - Tab navigation

**Form Controllers**:

- `nested_fields_controller.js` - Dynamic nested forms (add/remove fields)
- `checkbox_group_controller.js` - Checkbox group interactions
- `toggle_controller.js` - Toggle switches
- `searchable_select_controller.js` - Searchable select dropdowns
- `searchable_or_custom_controller.js` - Custom searchable selects
- `ingredient_item_controller.js` - Ingredient form items
- `notes_controller.js` - Note fields

**Interaction Controllers**:

- `drag_drop_controller.js` - Drag and drop functionality
- `calendar_controller.js` - Calendar interactions
- `search_controller.js` - Search functionality
- `filter_controller.js` - Filter interactions
- `autoscroll_controller.js` - Auto-scrolling
- `flash_dismiss_controller.js` - Dismiss flash messages
- `frame_source_controller.js` - Turbo Frame source manipulation

**Pattern**:

- Hotwire (Turbo + Stimulus) for progressive enhancement
- Data attributes for controller attachment (e.g., `data-controller="modal"`)
- Server-rendered HTML with sprinkles of interactivity

### Naming Conventions

**Facades**:

- Pattern: `[Namespace]::[Resource]::[Action]Facade`
- Examples: `Recipes::IndexFacade`, `Admin::Recipes::EditFacade`
- Resource facades: `Admin::Recipes::ResourceFacade`

**Components**:

- Pattern: `[Name]Component` with optional namespace
- Examples: `ButtonLinkComponent`, `Table::RowComponent`
- Inline data: `Data = Struct.new(...)`

**Services**:

- Pattern: Verb-based naming
- Examples: `BuildRecipeIngredients`, `FlashService`
- Namespaced: `UserRecipes::ProcessParams`
- Include `Service` module for `.call` class method

**Jobs**:

- Pattern: `[Action]Job`
- Examples: `SessionCleanupJob`, `CategorizeIngredientsJob`

**Policies**:

- Pattern: `[Resource]Policy`
- Base policies: `Base::AdminPolicy`, `Base::AuthenticatedPolicy`

**Data Structures**:

- Pattern: `[Name]Data`
- Examples: `MenuItemData`, `ColumnData`, `ButtonLinkData`

**Controllers**:

- Web: `[Resource]Controller` or `[Namespace]::[Resource]Controller`
- API: `Api::[Resource]Controller`

### Authentication & Authorization

#### Dual Authentication System

**Web Authentication (Devise)**:

- Used for: Browser-based web interface
- Session storage: Rails session cookies
- Controllers: `AuthenticatedController` uses `before_action :authenticate_user!`
- Current user: Available via Devise's `current_user` and `Current.user`

**API Authentication (Custom Session Model)**:

- Used for: Mobile apps, SPA clients, API consumers
- Session storage: Database (`sessions` table)
- Token format: Bearer token in `Authorization` header
- Token generation: `SecureRandom.urlsafe_base64(32)` → 256 bits entropy
- Token lifetime: 2 weeks
- Controllers: `Api::BaseController` uses `Api::TokenAuthentication` concern
- Current session: Available via `Current.session`

#### Security Features

- **Secure tokens**: Cryptographically secure (32 bytes, 256 bits entropy)
- **Rate limiting**: 5 attempts per 15 minutes on auth endpoints
- **Session tracking**: IP address, user agent, last_used_at
- **Suspicious activity detection**: Warns on IP/user agent changes
- **Comprehensive logging**: All auth events logged with `AUTH_EVENT:` prefix
- **CSRF protection**: `same_site: :lax` cookies
- **Production security**: `secure: true` cookies (HTTPS only)

#### Authorization (Pundit)

- **Deny by default**: ApplicationPolicy returns `false` for all actions
- **Base policies**: `Base::AdminPolicy`, `Base::AuthenticatedPolicy`, `Base::UnauthenticatedPolicy`
- **Authorization location**: Checked in **facade initializers**, NOT controllers
- **Error handling**: ApplicationController rescues `Pundit::NotAuthorizedError`

Key files:

- `app/models/session.rb` - Custom Session model for API
- `app/controllers/concerns/api/token_authentication.rb` - Bearer token auth
- `app/controllers/concerns/rate_limitable.rb` - Rate limiting
- `app/policies/application_policy.rb` - Base authorization policy
- `docs/AUTHENTICATION_GUIDE.md` - Detailed authentication documentation
- `SECURITY_IMPROVEMENTS.md` - Security audit details

## Important Conventions

### Controller Organization

- **Public controllers**: Recipe browsing, landing pages (no auth)
- **Authenticated controllers**: Inherit from `AuthenticatedController` (Devise login required)
- **Admin controllers**: In `app/controllers/admin/` namespace (admin role required)
- **API controllers**: In `app/controllers/api/` namespace (inherit from `ActionController::API`, Bearer token required)

### Model Associations (Key Relationships)

- **Recipe**: Can be user-generated (`UserRecipe`) or admin-curated
- **RecipeIngredient**: Uses fractional quantities (numerator/denominator)
- **MealPlan**: User's planned meals
- **MealPlanIngredient**: Database VIEW (not a table) aggregating ingredients
- **ShoppingList**: Generated from meal plans
- **User**: Has many sessions (API), favorites, meal plans, shopping lists, user recipes
- **Session**: Custom model for API authentication (NOT Devise sessions)

### Route Organization

- **Main routes**: `config/routes.rb`
- **Admin routes**: `config/routes/admin.rb` (drawn via `draw "admin"`)
- **API routes**: `config/routes/api.rb` (drawn via `draw "api"`)

## Database Views

Uses `scenic` gem for database views:

- SQL definitions in `db/views/`
- Models extend `DatabaseView` base class
- Versioned (e.g., `meal_plan_ingredients_v01.sql`)
- Read-only (cannot be modified via ActiveRecord)

## Image Processing

- **Storage**: Active Storage with AWS S3 in production (`aws-sdk-s3` gem)
- **Transformations**: `image_processing` gem with ImageMagick/libvips
- **Attachments**: `has_one_attached :image` or `has_many_attached :images`

## Recipe Import

- **Model**: `RecipeImport` with URL validation
- **Parser System**: Multiple parsers in `app/lib/import/parsers/`
  - JSON-LD, Schema.org microdata, hRecipe microformat
  - `ParserSelector` chooses appropriate parser
- **Controller**: `UserRecipeImportsController` handles import flow
- **Ingredient Parsing**: `ParseIngredient` extracts structured data from strings

## AI Integration

- **Gem**: `ruby-openai` (though CategorizeIngredientsJob uses direct HTTP)
- **Primary Use**: Ingredient categorization via Claude API
- **Model**: `claude-sonnet-4-20250514`
- **Job**: `CategorizeIngredientsJob` runs daily at 1am
- **Batch Processing**: 75 ingredients at a time

## Email

- **Production**: Mailgun (`mailgun-ruby` gem)
- **Development**: Letter Opener Web at http://localhost:3000/letter_opener
- **Mailers**: Standard Rails mailers in `app/mailers/`

## Testing Considerations

- **Framework**: Minitest (Rails default)
- **Parallel execution**: Enabled by default
- **Fixtures**: Located in `test/fixtures/`
- **Coverage**: SimpleCov
- **JSON validation**: `json_matchers` gem for API tests
- **System tests**: Selenium WebDriver
- **Naming convention**: Method-style `def test_does_something` (NOT block-style `test "does something"`)
- **Base classes**: `ActiveSupport::TestCase`, `ApplicationSystemTestCase`

## Security Notes

- Sessions use cryptographically secure tokens (32 bytes, 256 bits entropy)
- Rate limiting prevents brute force attacks (5 attempts per 15 minutes)
- All authentication events logged with `AUTH_EVENT` prefix
- CSRF protection via `same_site: :lax` cookies
- Production cookies use `secure: true` (HTTPS only)
- Suspicious activity detection on API sessions (IP/user agent changes)
- See `SECURITY_IMPROVEMENTS.md` for complete security audit

## Development Workflow

1. Create feature branch from `master`
2. Make changes following architectural patterns above
3. Run tests: `bin/rails test`
4. Check code quality: `bin/rubocop`
5. Run security scan: `bin/brakeman`
6. Test authentication flows if modifying auth code
7. Check logs for `AUTH_EVENT` entries during auth testing
8. Commit with meaningful messages
9. Open pull request for review

## Key Architectural Decisions

Understanding WHY we made these choices:

1. **Facade over Fat Models**: Presentation logic belongs in facades, not models or controllers
2. **ViewComponent over Partials**: Typed, testable UI components with Ruby classes
3. **Struct-based Data Objects**: Type safety without external gems (no dry-types, dry-struct)
4. **SimpleDelegator over Draper**: Lightweight decorator pattern, no heavy dependencies
5. **Service Objects for Business Logic**: Keep models focused on persistence only
6. **Pundit for Authorization**: Authorization as first-class concern with deny-by-default
7. **Dual Authentication**: Devise (web) + custom Session (API) for flexibility
8. **Fractional Quantities**: Numerator/denominator (not decimals) for precision in recipes
9. **Database Views**: For complex aggregations (Scenic gem for versioning)
10. **AI Integration**: Claude API for intelligent ingredient categorization
11. **Solid Stack**: Database-backed cache, queue, and cable (no Redis/Sidekiq)
12. **Hotwire over React/Vue**: Server-rendered with progressive enhancement
13. **CollectionBuilder**: Centralized pagination/search logic (DRY)
14. **Facade-Level Authorization**: Check permissions before building view data
15. **Request-Scoped Current**: Thread-safe request context via `ActiveSupport::CurrentAttributes`
