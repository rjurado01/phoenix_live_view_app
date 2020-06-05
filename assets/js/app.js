// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into its own CSS file.
import '../css/app.css'

// webpack automatically bundles all modules in your entry points.
// Those entry points can be configured in 'webpack.config.js'.

// Import dependencies
import 'phoenix_html'
import {Socket} from 'phoenix'
import LiveSocket from 'phoenix_live_view'
import NProgress from 'nprogress'

const toBase64 = file => new Promise((resolve, reject) => {
  const reader = new FileReader()
  reader.readAsDataURL(file)
  reader.onload = () => resolve(reader.result)
  reader.onerror = error => reject(error)
})

// HOOKS
const Hooks = {}

Hooks.uploadImage = {
  mounted() {
    this.el.addEventListener('input', () => {
      if (this.el.files[0].size > 500000) {
        alert('File max size is 0.5 Mb') // eslint-disable-line no-alert
        this.el.value = ''
      } else if (!this.el.files[0].type.match(/image/)) {
        alert('File is not a image') // eslint-disable-line no-alert
        this.el.value = ''
      } else {
        toBase64(this.el.files[0]).then(base64 => {
          const hidden = document.getElementById(`${this.el.id}_base64`)
          hidden.value = base64
          hidden.focus() // this is needed to register the new value with live view

          const preview = document.getElementById(`${this.el.id}_preview`)
          if (preview) preview.src = base64
        })
      }
    })
  }
}

// Initialize liveSocket
const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
const liveSocket = new LiveSocket('/live', Socket, {
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', () => NProgress.start())
window.addEventListener('phx:page-loading-stop', () => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from './socket'
