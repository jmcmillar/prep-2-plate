import { Controller } from '@hotwired/stimulus';
import focusTrap from "focus-trap"
export default class extends Controller {
  static targets = ['modal', 'content', 'overlay', 'wrapper'];

  static values = { open: Boolean };

  connect() {
    this.defaultContent = this.contentTarget.innerHTML;
  }

  disconnect() {
    this.defaultContent = "";
  }

  toggle(event) {
    this.openValue = !this.openValue;
    this.setModalContents(event);
  }

  // setModalContents(event) {
  //   if (event.currentTarget.dataset.modalUrl !== undefined) {
  //     // console.log(event.currentTarget.dataset.modalUrl);
  //     // this.contentTarget.querySelector("turbo-frame").src = event.currentTarget.dataset.modalUrl;
  //     this.contentTarget.innerHTML = `<turbo-frame src="${event.currentTarget.dataset.modalUrl}"></turbo-frame>`;
  //   }
  //   if (event?.dataset?.modalContent !== undefined) {
  //     this.contentTarget.innerHTML = modalContent;
  //   }
  // }
  setModalContents(event) {
    const url = event.currentTarget.dataset.modalUrl;
    if (url) {
      const frameId = 'modal';
      this.contentTarget.innerHTML = `
        <turbo-frame id="${frameId}" src="${url}">
          <div class="p-6 space-y-4 animate-pulse">
            <div class="h-6 bg-gray-300 rounded w-3/4"></div>
            <div class="h-4 bg-gray-300 rounded w-5/6"></div>
            <div class="h-4 bg-gray-300 rounded w-2/3"></div>
            <div class="h-4 bg-gray-300 rounded w-1/2"></div>
            <div class="h-10 bg-gray-300 rounded mt-6 w-1/3"></div>
          </div>
        </turbo-frame>
      `;
    }
  }

  openValueChanged() {
    this.openValue ? this.open() : this.close();
  }

  closeWithKeyboard(e) {
    if (e.keyCode === 27 && this.openValue) {
      this.openValue = false;
    }
  }

  open() {
    this.handleWrapperHidden();
    this.setFocusLock();
    this.setScrollLock();
    setTimeout(() => {
      this.animateOverlay();
      this.animateModal();
    }, 300);
  }

  close() {
    this.animateOverlay();
    this.animateModal();
    this.setFocusLock();
    this.setScrollLock();
    setTimeout(() => {
      this.handleWrapperHidden();
      this.contentTarget.innerHTML = this.defaultContent;
    }, 300);
  }

    setFocusLock() {
    if (this.openValue) {
      this.focusTrap = focusTrap.createFocusTrap(this.modalTarget, { 
        escapeDeactivates: false,
        onDeactivate: () => this.openValue = false
      });
      this.focusTrap.activate();
    } else if (this.focusTrap) {
      this.focusTrap.deactivate();
      this.focusTrap = null;
    }
  }

  setScrollLock() {
    document.body.classList.toggle('overflow-hidden', this.openValue);
  }

  handleWrapperHidden() {
    const hidden = !this.openValue;
    this.wrapperTarget.classList.toggle('hidden', hidden);
    this.wrapperTarget.setAttribute('aria-hidden', String(hidden));
    this.wrapperTarget.classList.toggle('h-screen', this.openValue);
    this.wrapperTarget.classList.toggle('w-screen', this.openValue);
  }

  animateOverlay() {

    this.overlayTarget.classList.toggle('opacity-80', this.openValue);
    this.overlayTarget.classList.toggle('opacity-0', !this.openValue);
  }

  animateModal() {
    this.modalTarget.style.transform = this.openValue
      ? null
      : 'translateY(10%)';
    this.modalTarget.classList.toggle('opacity-0', !this.openValue);
  }
}
