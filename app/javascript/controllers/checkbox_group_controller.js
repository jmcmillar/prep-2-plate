import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    collection: Array,
    whitelist: Array
  }
  static targets = ["ids", "input"]

  connect() {
    this.initInputField();
    this.element.querySelector("input[type=text]").addEventListener('change', this.onChangedInput.bind(this));
  }

  initInputField() {
    const inputField = this.element.querySelector("input[type=text]");
    return new Tagify(inputField, this.inputOptions());
  }

  onChangedInput(event) {
    const valuesArr = JSON.parse(event.target.value || "[]");
    return this.setValues(valuesArr);
  }


  setValues(valueArr) {
    const values = valueArr.map(item => item.value)
    const ids = this.collectionValue.filter(item => values.includes(item.name)).map(item => item.id)
    const checkboxes = this.element.querySelectorAll("input[type=checkbox]");

    for (const checkbox of checkboxes) {
      checkbox.checked = ids.includes(+checkbox.value);
    }
  }

  inputOptions() {
    return ({
      whitelist: this.whitelistValue,
      maxTags: 10,
      dropdown: {
        maxItems: 20,
        classname: "tagify__inline__suggestions",
        enabled: 0,
        closeOnSelect: false,
        searchKeys: ['name']
      }
    })
  }
}




