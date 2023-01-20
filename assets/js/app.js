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

// import {Jodit} from "jodit/build/jodit.es2018.min.js"
import {Jodit} from "jodit/build/jodit.es2018.js"

let Hooks = {};
Hooks.Editor = {
    mounted() {
        const slide_id = this.el.dataset.slide;
        const editor = Jodit.make('#editor', {
            "minHeight": 900,
            "maxHeight": 900,
            "minWidth": 1200,
            "maxWidth": 1200,
            "uploader": {
                insertImageAsBase64URI: false,
                url: '/uploads',
                imagesExtensions: ['jpg', 'png', 'jpeg', 'gif'],
		            prepareData: function (formdata) {
			              formdata.append('slide_id', slide_id);
		            }
            },
            filebrowser: {
                createNewFolder: false,
                deleteFolder: false,
                showFoldersPanel: false,
                ajax: {
                    url: '/list_uploads',
		                prepareData: function (data) {
                        data.slide_id = slide_id;
                        return data;
		                }
			              // headers: {
				            //     'X-CSRF-Token': document
					          //         .querySelector('meta[name="csrf-token"]')
					          //         .getAttribute('content')
			              // },
                },
            }
        });
        editor.s.focus();

        this.editor = editor;
        this.editor.e.on('change', () => {
            if ( this.editor.getEditorValue() != this.el.value ) {
                this.el.value = editor.getEditorValue();
            }
        });

        val = this.editor.getEditorValue();
        if (this.el.value !== val) {
            this.editor.setEditorValue(this.el.value);
        }
        console.log("What!");
    },
    updated() {
        console.log("Slide id:"+this.slide_id);
        console.log("getting here");
        val = this.editor.getEditorValue();
        if (this.el.value != val) {
            console.log("getting here!!!!");
            this.editor.setEditorValue(this.el.value);
        }
    }
};

function get_SrcAddr(el) {
    return el.getAttribute("src").split("/").slice(-1);
}

function onPlayerReady(event) {
    window.player = event.target;
    window.player_toggle = window.player.playVideo;
    window.presentation.pushEvent("video_ready",
                                  {idx: window.presentation.el.getAttribute("data"),
                                   video_title: event.target.videoTitle
                                  });
}

function onYouTubeIframeAPIReady() {
    /*gets called when API Ready*/
}
window.onYouTubeIframeAPIReady = onYouTubeIframeAPIReady;

function setUpPlayer(el) {
    var iframe = el.querySelector("iframe");
    if (iframe !== null) {
        addr = get_SrcAddr(iframe)[0];
        width = iframe.getAttribute("width");
        height = iframe.getAttribute("height");
        style = iframe.getAttribute("style");
        console.log(addr);
        console.log(width);
        console.log(height);

        const div = document.createElement("div");
        div.setAttribute("id", "play");
        div.setAttribute("style", style);
        iframe.replaceWith(div);

        player = new YT.Player('play', {
            videoId: addr,
            height: height,
            width: width,
            events: {
                'onReady': onPlayerReady
            }
        });
    }
}

Hooks.VideoList = {
    mounted() {
        setUpPlayer(this.el);
        window.presentation = this;
    },
    updated() {
        setUpPlayer(this.el);
        window.presentation = this;
    }
};

window.addEventListener(
    "phx:toggle-player", e => {
        console.log(e);
        if (window.player_toggle === window.player.playVideo) {
            window.player_toggle = window.player.pauseVideo;
            window.player.playVideo();
        } else {
            window.player_toggle = window.player.playVideo;
            window.player.pauseVideo();
        }
    }
)


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"});
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());


// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// liveSocket.enableLatencySim(8000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

window.Jodit = Jodit;
