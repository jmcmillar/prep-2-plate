with ingredient_unit_totals as
  (select meal_plans.id as meal_plan_id,
  ingredients.name,
  recipe_ingredients.ingredient_id,
  measurement_units.name AS unit_name,
  SUM(recipe_ingredients.quantity::FLOAT) AS quantity,
  SUM(CASE
          WHEN recipe_ingredients.denominator = 0 THEN 0
          ELSE recipe_ingredients.numerator::FLOAT / recipe_ingredients.denominator
      END) AS total_amount
  FROM meal_plans
  LEFT JOIN meal_plan_recipes ON meal_plan_recipes.meal_plan_id = meal_plans.id
  LEFT JOIN recipe_ingredients ON meal_plan_recipes.recipe_id = recipe_ingredients.recipe_id
  INNER JOIN ingredients ON recipe_ingredients.ingredient_id = ingredients.id
  LEFT JOIN measurement_units ON recipe_ingredients.measurement_unit_id = measurement_units.id
  GROUP BY meal_plans.id,
          recipe_ingredients.ingredient_id,
          measurement_units.name,
          ingredients.name)
SELECT meal_plan_id,
  ingredient_id,
  unit_name,
  name,
  quantity,
  CASE
      WHEN total_amount = 0 THEN ''
      WHEN FLOOR(total_amount) = total_amount THEN total_amount::INT::TEXT
      ELSE CASE
              WHEN FLOOR(total_amount) = 0 THEN
                      (WITH frac AS
                        (SELECT ROUND(total_amount * 24)::INT AS num,
                                24 AS denom),
                            reduced AS
                        (SELECT num / gcd(num, denom) AS n,
                                denom / gcd(num, denom) AS d
                          FROM frac) SELECT n || '/' || d
                      FROM reduced)
              ELSE
                      (WITH frac AS
                        (SELECT ROUND((total_amount - FLOOR(total_amount)) * 24)::INT AS num,
                                24 AS denom),
                            reduced AS
                        (SELECT num / gcd(num, denom) AS n,
                                denom / gcd(num, denom) AS d
                          FROM frac) SELECT FLOOR(total_amount)::TEXT || ' ' || n || '/' || d
                      FROM reduced)
          END
END AS formatted_amount
FROM ingredient_unit_totals
order by meal_plan_id,
  name
