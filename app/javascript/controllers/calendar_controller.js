import { Controller } from "@hotwired/stimulus";
import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import interactionPlugin from '@fullcalendar/interaction';

const EVENT_COLOR = "#1B8C57";
const PLUGINS = [dayGridPlugin, timeGridPlugin, listPlugin, interactionPlugin];
const TOOLBAR = {
  left: 'prev,next today',
  center: 'title',
  right: 'dayGridMonth,timeGridWeek,listWeek'
};

export default class extends Controller {
  static outlets = ["modal"]
  static values = { planId: Number, eventUrl: String }

  connect() {
    console.log(this.modalOutlet);
    this.getCalendar();
  }

  async getCalendar() {
    try {
      const response = await fetch(this.eventUrlValue);
      this.calendarItems = await response.json();
      await this.initializeCalendar();
    } catch (error) {
      console.log(error)
    }
  }

  initializeCalendar() {
    const calendar = new Calendar(this.element, this.calendarOptions());
    calendar.render();
  }

  calendarOptions() {
    return ({
      events: this.calendarItems,
      eventColor: EVENT_COLOR,
      plugins: PLUGINS,
      initialView: 'dayGridMonth', // Fixed: should be string, not PLUGINS.dayGridPlugin
      headerToolbar: TOOLBAR,
      dateClick: (info) => this.addRecipeEvent(info)
    })
  }

  addRecipeEvent(info) {
    this.modalOutlet.contentTarget.querySelector("turbo-frame").setAttribute(
      "src",
      `/admin/meal_plans/${this.planIdValue}/meal_plan_recipes/new?date=${info.dateStr}`
    )
    this.modalOutlet.toggle()
  }
}
