# React-Brunch-Base
A boilerplate for React with Brunch

## Brunch
![bwc-logo](http://brunch.io/images/svg/brunch.svg)

This is HTML5 application, built with
[Brunch](http://brunch.io) and [React](http://facebook.github.io/react/).

## Getting started
* Install (if you don't have them):
    * [Node.js](http://nodejs.org): `brew install node` on OS X
    * [Brunch](http://brunch.io): `npm install -g brunch`
    * [Bower](http://bower.io): `npm install -g bower`

## Project Installation
* Install:
    * Clone this repo
    * Run `npm install` in the root directory to install all [Brunch](http://brunch.io) packages
    * Run `bower install` in the root directory to install all project dependencies
* Workflow:
    * `brunch watch --server` — watches the project with continuous rebuild. This will also launch HTTP server with [pushState](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history).
    * `brunch watch -s -p xxxx` watches the project and launches the HTTP server on port XXXX.
    * `brunch build --production` — builds minified project for production
    * `public/` dir is fully auto-generated and served by HTTP server.  Write your code in `app/` dir.
    * Place static files you want to be copied from `app/assets/` to `public/`.
    * [Brunch site](http://brunch.io), [React site](http://facebook.github.io/react/)
