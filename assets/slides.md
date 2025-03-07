---
marp: true
style: |

  section h1 {
    color: #6042BC;
  }

  section code {
    background-color: #e0e0ff;
  }

  footer {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 100px;
  }

  footer img {
    position: absolute;
    width: 120px;
    right: 20px;
    top: 0;

  }
  section #title-slide-logo {
    margin-left: -60px;
  }
---

# LiveView and Web Components
Chris Nelson
@superchris.launchscout.com (BlueSky)
![h:200](/images/full-color.png#title-slide-logo)

---

# Hi!
## Chris Nelson
### @superchris.launchschout.com (bsky)
- Co-Founder of Launch Scout
- Creator of LiveElements
- Creator of LiveState
- Contributor to wasmex

---

# Agenda
- Why WebComponents and LiveView?
- How to use them with LV
- LiveElements
- Some gotchas

---

# What's a Web Component
- Technically 3 different specs
  - Custom elements
  - Shadow DOM
  - template elements
- Custom HTML elements are what we care about most

---

# Why I believe they are the best option for extending LV
- Built in to your browser: No JS frameworks needed!
- Future proof
- They have superpowers no framework can match
  - Shadow DOM (slots and parts)
  - ElementInternals
- The cleanest interface with LiveView

---

# Using a Custom Element
- Add javascript definitions
- Use them like any other HTML element
- In some cases this may be good enough!

---

# How does LiveView talk to an element?
- Pass data via attributes and child elements
- Your element will need re-render when these change!
- For complex data, JSON serialization is a solid choice

---

# How does an Element talk to LV?
- Custom Events for Custom Elements
- You can define your own payload
- Need `phoenix-custom-event-hook`
  - Hopefully soon to be obsoleted by LV PR

---

# LiveElements
- hex package containing `custom_element` macro
- A `<custom-element>` becomes a `<.functional_component>`
- serializes data as json into attributes
- declaratively sends custom events to LV
  - for now using `phoenix-custom-event-hook`

---

# [Demo time!](/airports)

---

# `<.autocomplete_input>`
  - starts in a closed state
  - sends events for search and commit
  - items are passed in attribute
- open/close is client only state

---
## Dispatching a custom event
```js
this.dispatchEvent(
  new CustomEvent('autocomplete-search', { detail: { query: this.searchInput.value, name: this.name } }));
```

---

# Map elements
- `<gmpx-api-loader>`
- `<gmp-map>`
- `<gmp-map-advance-marker>`
- Display only, no events are sent

---

# Setting up our javascript
### app.js
```js
import '@googlemaps/extended-component-library/api_loader.js';
import '@launchscout/autocomplete-input'
import PhoenixCustomEventHook from 'phoenix-custom-event-hook'

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: { PhoenixCustomEventHook }
})
```

---
# Using LiveElements
### In the the LiveView...
```elixir
  use LiveElements.CustomElementsHelpers

  custom_element :autocomplete_input,
    events: ["autocomplete-search", "autocomplete-commit"]

```
- creates `.autocomplete_input` to wrap `<autocomplete-input>`
- listens for the events and pushes them to LiveView

---
## Meanwhile, in our template
```html
<.form for={@form} phx-submit="choose_favorite" class="flex gap-4 items-end mb-6">
  <div class="form-group">
    <label class="block text-sm font-medium mb-1" for="airport_code">Airport Code</label>
    <.autocomplete_input
      name="airport_code"
      id="airport-autocomplete"
      display-value="Search by name or code"
      min_length={3}
      items={options_for(@airports)}
    />
  </div>
</.form>

```
---
# Handling events
```elixir
  @impl true
  def handle_event("autocomplete-search", %{"name" => "airport_code", "query" => query}, socket) do
    {:noreply, socket |> assign(:airports, Airports.search_airports(query))}
  end

  def handle_event("autocomplete-commit", %{"name" => "airport_code", "value" => value}, socket) do
    {:noreply,
     socket
     |> assign(:airport, Airports.get_airport_by_code(value))
     |> assign(:airports, [])}
  end
```
---
# Displaying the map
```html
  <%= if @airport do %>
    <div class="map-container">
      <gmp-map
        id="my-map"
        center={coordinates(@airport)}
        zoom="10"
        map-id="DEMO_MAP_ID"
        class="google-map"
      >
        <gmp-advanced-marker
          class="pannable"
          position={coordinates(@airport)}
          title={@airport.name}
        >
          <div class="airport-marker">
            <div class="marker-content">
              <div class="airport-code">{@airport.ident}</div>
              <div class="airport-name">{@airport.name}</div>
            </div>
          </div>
        </gmp-advanced-marker>
      </gmp-map>
    </div>
  <% end %>

```
---

# Challenges with LV and Custom Elements
- LiveView replaces elements when it renders
- Which is fine..
  - except when it's not :)
- Hence the "flash" on airport change

---

# Workarounds
- `phx-update="ignore"`
  - will not touch the element or its descendants
  - except data attributes
  - nested will not be re-rendered
- Render in a Shadow DOM
  - LiveView cannot reach inside a Shadow DOM
  - this breaks for slotted or child elements

---

# Building your own custom elements
- Great way to wrap js library
  - e. g. FullCalendar, ChartJS
- Choose a library, don't commit to a framework
  - Our favorite is Lit
- Keep your elements "dumb"
  - render state
  - dispatch events

---

# [LiveState](github.com/launchscout/live_state)
## If the limitations of LV are a dealbreaker
- Connects js to a stateful channel
- Think LV without the rendering
  - client libs for custom elements, React, signals
- It's possible to use LiveState with LV
  - Using after_render hook to pubsub to a LiveState sync channel
  - js lib uses LiveState to subscribe to assigns

---

# LiveView/Livestate [demo](http://localhost:4001/people)

---

# Thanks!

![h:400](/images/qr-code.png)

---

## Resources
- github:launchscout/codebeam_2025
- github:launchscout/live_elements
- github:launchscout/live_state
- github:superchris/lv_hook_experiment

---