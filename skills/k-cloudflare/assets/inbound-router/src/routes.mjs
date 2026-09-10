/** Synced from inbound-routes.json — edit JSON then redeploy worker + run sync script. */
export const ROUTES = {
  "mail@<yourdomain.com>": ["<personal@hotmail.com>", "<primary@gmail.com>"],
  "contact@<yourdomain.com>": ["<labs@gmail.com>", "<primary@gmail.com>"],
  "personal@<yourdomain.com>": ["<personal@hotmail.com>", "<primary@gmail.com>"],
};

export const DEFAULT_DESTINATIONS = ["<primary@gmail.com>"];
