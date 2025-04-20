## React Router SPA Framework mode integration for Ruby on Rails

The react_router_rails_spa gem integrates [React Router in SPA Framework mode](https://reactrouter.com/how-to/spa) with your Ruby on Rails application.
The React app is built as static assets in your Rails `public` folder, and so it can be deployed on your current production server with minimal, if any, configuration changes.

Benefit from state-of-the-art React SPA technlologies –
the integrated client-side router, loader data-fetching pattern,
automatic code-splitting, and development server with HMR,
without the costs and complexities of running a separate front-end server.

If you are using Next.js, not for SEO
but only for convenience,
if you are not using SSR but fetching data on the client-side,
then this gem will provide you with a similarly convenient but simpler, cheaper and more performant solution.

 You may be considering the traditional approaches to React and Rails integration such as [Webpacker](https://github.com/rails/webpacker),
[jsbundling-rails](https://github.com/rails/jsbundling-rails), [Vite Ruby](https://github.com/ElMassimo/vite_ruby)
but concerned about installing and configuring additional packages, and avoiding SPA pitfalls.
With a single gem and a single command, this gem sets up all that you need in  "Omakase"-style – Rails route and controller setup, an integrated client-side router, automatic per-route code-splitting, and the loader data-fetch pattern to eliminate data-fetch waterfalls.

## Who is it for?

Consider trying out this gem if you fit any of the following descriptions.

- You want to integrate React into a Ruby on Rails application.
  - You want an out-of-the-box solution for a state-of-the-art multipage React application. You do not enjoy installing React, React Router, Tailwind, configuring code-splitting, and deciding the data-loading scheme that you will use throughout your application. You want "Omakase" on the front-end as well as your Rails back-end. 
  - Your Ruby on Rails application already has ERB (Hotwire)  pages.
- You do not need SEO for the React generated pages (you don't need SSR/SSG).
  - You can always use ERB views for the pages that neww SEO.
- You do not want to host multiple servers for your frontend and your backend.
  - You do not want to incur the additional costs, complexity, and authentication concerns that are inherent when dealing with multiple servers.
  - You want to simply deploy your React frontend as static assets on a single server, inside your Ruby on Rails `public` folder.
- You have many pages, and you want to reduce the initial JavaScript payload size by using automatic code-splitting and lazy-loading, but without sacrificing performance due to request waterfalls.

## Installation

The React Router application will be installed inside the `frontend` directory. We assume that you have an existing Ruby on Rails application.

Add this line to your application's Gemfile:

```ruby
gem 'react_router_rails_spa'
```

Then, run:

```shell
bundle install
bin/rails generate react_router_rails_spa:install
```

This will create a new directory called `frontend` inside the project root.
It will also create a React bootstrap endpoint for all paths starting with `/react`.
The endpoint will be handled by `ReactController#show`.

You will also have rake tasks for starting the dev server and building/previewing the React app.

As part of the integration, we provide utilities for using the robust CSRF protection built into Ruby on Rails from your React application.

## Running the React Router development server

React Router is built with Vite and uses the Vite development server to provide a Hot Module Replacement (HMR) capability, that is very helpful for routing editing of pages.
However, the development server is not used in production and will not widely represent the application's behavior in production.
We therefore strongly recommend that you build the React Router assets into the `public` folder and preview it before deploying into production. 

Start the Vite development server with HMR with the following command (we assume that the Ruby on Rails server is already running (with either `bin/rails s` or `bin/dev`).

```shell
bin/rails react_router:dev
```

Access the development server from the URL outputted from this command (Typically `http://localhost:5173/react`)

To preview the production build, run the following command.
```shell
bin/rails react_router:preview
```

This will build the React Router application into the Rails `public` folder, and the React Router application will be available from the Rails development server (puma) at `http://localhost:3000/react`.
The preview will be representative of the production app's behavior.

## Deployment

This gem integrates with the Ruby on Rails Asset pipeline.

The React Router application is automatically built whenever `bin/rails assets:precompile` is run
and therefore no changes should be required since your Ruby on Rails application should already do this.

If your deployment pipeline does not already install Node (for example, you have a "no-build" deployment for Rails),
then install it in your CI/CD environment since building the React Router application will require it.

## Background

Ruby on Rails has officially supported bundling of complex JavaScript frontend libraries,
first with [Webpacker](https://github.com/rails/webpacker),
and currently with [jsbundling-rails](https://github.com/rails/jsbundling-rails).
We also have [Vite Ruby](https://github.com/ElMassimo/vite_ruby) with an integrated dev server, HMR and other goodies.

However, on February 14th, 2025,
the React team announced the [official deprecation of Create React App (CRA)](https://react.dev/blog/2025/02/14/sunsetting-create-react-app).
Instead, they suggested developers should use a framework that builds single-page apps
(SPA) deployable to a CDN or a static hosting service –
In other words, SPA frameworks such as Next.js or React Router.
Importantly,
they advised
against [building a React app from scratch](https://react.dev/learn/build-a-react-app-from-scratch)
unless your app has constraints not well-served by existing SPA frameworks.

This approach poses challenges to the traditional Rails integration solutions.
They all compile the React applications to a single JavaScript file
that is then loaded from an ERB file (the React bootstrap HTML) containing helper functions such as
`javascript_include_tag` (jsbundling-rails), `javascript_pack_tag` (webpacker), or `vite_javascript_tag` (vite-rails).
However, SPA frameworks do not just compile to a single JavaScript file.
Instead,
they additionally generate their own React bootstrap HTML file which includes many framework-specific optimizations
(React Router v7 generates this using SSG from `app/root.tsx`).

This gem uses the bootstrap HTML file
generated by the SPA framework instead of an ERB file.
This is served through an ActionController endpoint,
enabling you to use cookies to send session-specific information on the first HTML load
and is used in this gem to send CSRF tokens.

## Notes when using Rails in API mode

Ruby on Rails provides an API mode that removes many frontend features.
Importantly, API mode implies a stateless API server that does not support cookies.
It removes the middleware for cookie handling and also for CSRF protection.

To fully benefit from hosting your React app inside Rails' `public` folder, we recommend that you avoid API-mode and instead use cookies for authentication.
If you want to convert your API-mode application to use cookies, make sure to also restore CSRF features.
Otherwise, your app will be vulnerable to CSRF attacks.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/naofumi/react_router_rails_spa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/naofumi/react_router_rails_spa/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ReactRouterRailSpa project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/naofumi/react_router_rails_spa/blob/main/CODE_OF_CONDUCT.md).
