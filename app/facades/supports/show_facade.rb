class Supports::ShowFacade < BaseFacade
  DEFAULT_SUPPORT_EMAIL = "prep2plateplanner@gmail.com".freeze

  def active_key
    :none
  end

  def support_email
    ENV.fetch("SUPPORT_EMAIL", DEFAULT_SUPPORT_EMAIL)
  end

  def faqs
    [
      FaqData["How do I reset my password?",
              "Tap “Forgot your password?” on the sign-in screen and enter your email. We'll send you a link to choose a new password."],
      FaqData["I didn't get my confirmation email.",
              "Check your spam or promotions folder. If it isn't there, request a new one from the sign-in screen or email us and we'll help."],
      FaqData["How do I import a recipe?",
              "Paste the recipe's web address into the import form. We read the recipe details from the page so you can review and save them to your recipes."],
      FaqData["How do I make a shopping list?",
              "Add recipes to your meal plan, then export it to a shopping list. Ingredients are combined and grouped by aisle."],
      FaqData["How do I delete my account?",
              "Email us from the address on your account and ask for it to be deleted. We'll remove your account and its data and confirm when it's done."]
    ]
  end
end
