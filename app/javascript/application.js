// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
import { Application } from '@hotwired/stimulus';
import './controllers';
import 'trix';
import '@rails/actiontext';
//= require rails-ujs
//= require turbolinks
//= require_tree .
//= require 'chartkick'
//= require 'chart.js'
import "trix"
import "@rails/actiontext"
import "./channels/notifications_channel";

import TextLimitController from "./controllers/text_limit_controller";
const application = Application.start();
application.register("text-limit", TextLimitController);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };