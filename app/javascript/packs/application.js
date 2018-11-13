import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from "activestorage";

import 'jquery'
import 'popper.js'
import 'bootstrap'
import '../src/application'

global.$ = require('jquery');

Rails.start();
Turbolinks.start();
ActiveStorage.start();
