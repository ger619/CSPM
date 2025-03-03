// Configure your import map in config/import.rb. Read more: https://github.com/rails/importmap-rails

import '@hotwired/turbo-rails';
import 'controllers';
import 'trix';
import '@rails/actiontext';
//= require rails-ujs
//= require turbolinks
//= require_tree .
//= require 'chartkick'
//= require 'chart.js'
import "trix"
import "@rails/actiontext"
import $ from "jquery";
import "datatables.net-dt/css/jquery.dataTables.min.css";
import "datatables.net";

$(document).ready(function () {
    $("#yourTableId").DataTable();
  });
  