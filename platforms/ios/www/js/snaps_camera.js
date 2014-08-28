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
  },

  sendMMS: function (image, success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "sendMMS", [ image ])
  }
}

module.exports = SnapsCamera;
