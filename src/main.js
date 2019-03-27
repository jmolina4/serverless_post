'use strict'

exports.handler = function (event, context, callback) {
    console.log("Hello World");
    callback(null, "some success message");
}