var SnapsCamera = {
  openCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "openCamera", [])
  },

  closeCamera: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "closeCamera", [])
  }
}

module.exports = SnapsCamera;
