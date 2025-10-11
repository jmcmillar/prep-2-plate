import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    "connected"
  }
  drag(event) {
    event.dataTransfer.setData("text/plain", JSON.stringify({
      recipe_id: event.target.dataset.recipeId,
      from_day: event.target.dataset.day // optional for remove
    }))
  }

  allowDrop(event) {
    event.preventDefault()
  }

  drop(event) {
    event.preventDefault();
    const data = JSON.parse(event.dataTransfer.getData("text/plain"));
    const day = event.target.closest("[data-day]").dataset.day;
  
    // Perform the fetch request
    fetch("/meal_planner/add_to_plan", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ recipe_id: data.recipe_id, day: day, from_day: data.from_day })
    })
      .then(response => response.text())  // Get the text response (Turbo Stream)
      .then(html => {
        // Parse and insert the Turbo Stream response
        const turboStream = new DOMParser().parseFromString(html, "text/html");
        const turboStreamElement = turboStream.querySelector("turbo-stream");
        
        if (turboStreamElement) {
          // Manually inject the Turbo Stream response into the DOM
          document.body.appendChild(turboStreamElement);
        }
      })
      .catch(error => console.error("Error updating plan:", error));
  }
}
