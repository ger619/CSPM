import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="drag"

const dataResourceID = 'data-resource-id';

const dataParent = 'data-parent';


let url;

let resourceID;


let newPosition;

export default class extends Controller {
  connect() {
    // Initialization code if needed
  }

  dragStart(event) {
    resourceID = event.target.getAttribute(dataResourceID);
    url = event.target.getAttribute('data-url');
    event.dataTransfer.effectAllowed = 'move';
  }

  drop(event) {
    let parentID = event.target.getAttribute(dataParent);
    const dropTarget = this.findDropTarget(event.target, parentID);
    const draggedItem = document.querySelector(`[data-resource-id="${resourceID}"]`);
  }
  dragEnd(event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
  }

  dragOver(event) {
    event.preventDefault();
    return true;
  }

  dragEnter(event) {
    event.preventDefault();
    return true;
  }

  findDropTarget(target, parentID) {
    if (target === null) {
      return null;
    }
    if (target.id === parentID) {
      return null;
    }
    if (target.classList.contains('draggable')) {
      return target;
    }
    return this.findDropTarget(target.parentElement, parentID);
  }
}