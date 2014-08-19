var SnapsCamera = {
  openCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "openCamera", [])
  },

  closeCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "closeCamera", [])
  },

  addSticker: function (image, success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "addSticker", [ image ])
  },

  reset: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "reset", [ ])
  }
}

module.exports = SnapsCamera;
