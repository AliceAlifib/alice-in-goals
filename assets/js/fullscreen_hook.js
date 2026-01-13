export default {
  mounted() {
    // Listen for fullscreen toggle events from LiveView
    this.handleEvent("toggle_fullscreen", () => {
      const iframe = document.getElementById("unity-frame");

      if (!iframe) return;

      // Check if already in fullscreen
      if (document.fullscreenElement) {
        // Exit fullscreen
        if (document.exitFullscreen) {
          document.exitFullscreen();
        }
      } else {
        // Enter fullscreen
        if (iframe.requestFullscreen) {
          iframe.requestFullscreen();
        } else if (iframe.webkitRequestFullscreen) {
          // Safari
          iframe.webkitRequestFullscreen();
        } else if (iframe.msRequestFullscreen) {
          // IE11
          iframe.msRequestFullscreen();
        }
      }
    });
  },
};
