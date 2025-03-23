import type { Config } from "@react-router/dev/config";

export default {
  // Config options...
  // For our React Router app, we will turn off Server-side render
  // use SPA mode!!
  ssr: false,
  // In the above, we have decided to serve the React Router app from "/react-router/".
  // The basename options tell React Router to manage this when generating
  // Link tags, for example.
  basename: "/react-router/"
} satisfies Config;
