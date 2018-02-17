// load styles
require('./style.css');

var Manager = require('./app/manager');

var i18n = require('./app/i18n');
var Game = require('./app/game');
var Instead = require('./app/instead');
var UI = require('./app/ui');
var Menu = require('./app/menu');

document.addEventListener(
    'DOMContentLoaded',
    function onLoad() {
        if ('INSTEADjs' in window) {
            Game.loadConfig(window['INSTEADjs']); // eslint-disable-line dot-notation
            if (window['INSTEADjs']['translation']) { // eslint-disable-line dot-notation
                i18n.load(window['INSTEADjs']['translation']); // eslint-disable-line dot-notation
            }
        }
        Manager.init();
        // initialization of INSTEAD components
        Instead.init();
        UI.init('#instead', Instead.handlers);
        Menu.init(UI.element, Instead.handlers);
    }
);
