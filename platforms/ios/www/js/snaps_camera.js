var SnapsCamera = {
  openCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "openCamera", [])
  },

  closeCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "closeCamera", [])
  },

  showCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "showCamera", [])
  },

  hideCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "hideCamera", [])
  },

  addSticker: function (image, success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "addSticker", [ image ])
  }
}

module.exports = SnapsCamera;
