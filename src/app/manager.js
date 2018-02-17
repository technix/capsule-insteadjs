var $ = require('jquery');

var Game = require('./game');
var Instead = require('./instead');
var UI = require('./ui');
var Preloader = require('./ui/preloader');

var gamepath = './game/';
var gameList = gamepath + 'game.json';
var allGames;

var Manager = {
    init: function init() {
        var self = this;
        var gameListURL = gameList + '?' + Math.random().toString(36).substring(7); // avoid cached response
        $.get(gameListURL, function listGames(data) {
            allGames = typeof data === 'object' ? data : JSON.parse(data);
            var gameIds = Object.keys(allGames);
            if (gameIds.length === 1) {
                // If there is only one game, start it immediately
                self.startGame(gameIds[0]);
            }
        });
    },
    startGame: function startGame(gameid) {
        window.location.hash = '#/' + gameid;
        Instead.initGame({
            id: gameid,
            path: allGames[gameid].path || gamepath + gameid + '/',
            name: allGames[gameid].name,
            details: allGames[gameid].details,
            ownTheme: allGames[gameid].theme,
            stead: allGames[gameid].stead
        });
        if (Game.preload) {
            this.preload(gameid);
        }
        UI.show();
        Instead.startGame(Game.autosaveID);
    },
    preload: function preload(gameid) {
        Preloader.load(
            allGames[gameid].preload,
            function preloadProgress() {},
            function preloadSuccess() {}
        );
    }
};

module.exports = Manager;
