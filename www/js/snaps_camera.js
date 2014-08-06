var SnapsCamera = {
  getPicture: function (success, failure) {
    cordova.exec(success, failure, "SnapsCamera", "openCamera", [])
  }
}

module.exports = SnapsCamera;
