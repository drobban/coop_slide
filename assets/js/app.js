// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"


// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"


// import DecoupledEditor from "@ckeditor/ckeditor5-build-decoupled-document";
// import DecoupledEditor from "ckeditor5-custom-build";
import {Jodit} from "jodit/build/jodit.es2018.min.js"
// import ClassicEditor from "@vndywhat/ckeditor5-build-classic-full-with-base64-upload-and-spoiler";
// import Base64UploadAdapter from '@ckeditor/ckeditor5-upload/src/adapters/base64uploadadapter';


let Hooks = {};
Hooks.Editor = {
    mounted() {
        this.target = this.el.getAttribute('for');
        const editor = Jodit.make(`#${this.target}`, {
            "minHeight": 768,
            "maxHeight": 768,
            "minWidth": 1024,
            "uploader": {
                "insertImageAsBase64URI": true
            }
        });
        editor.s.focus();
        editor.s.insertHTML(this.el.value);
        editor.e.on('change', () => {
            if ( editor.value !== this.el.value ) {
                this.el.value = editor.value;
            }
        });
        this.editor = editor;
    },
    updated() {
        this.editor.s.focus();
        this.editor.setEditorValue(this.el.value);
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())


// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.Jodit = Jodit
