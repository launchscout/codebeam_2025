---
marp: true
---

# LiveView and Web Components

---

# Me
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

# The custom elements
- `<autocomplete-input>`
- `<gmpx-api-loader>`
- `<gmp-map>`
- `<gmp-map-advance-marker>`

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
- no need to wrap the map elements
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
  <.button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg">
    Mark as favorite
  </.button>
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

  def handle_event("choose_favorite", %{"airport_code" => airport_code}, socket) do
    {:noreply, socket |> assign(:favorite_airport, Airports.get_airport_by_code(airport_code)) |> assign(:airports, [])}
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

# What's worked for us when building Custom Element
- Choose a library, don't commit to a framework
- Keep your elements "dumb"
  - render state
  - dispatch events
- smaller is better

---

# Useful things to know
- LV replaces elements when it renders
  - if your element has internal state this gets tricky
  - `phx-update="ignore" can help
  - but watch out for slots!
- LV can't reach into the Shadow DOM

---

# Thanks!

---