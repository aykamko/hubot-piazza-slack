# [hubot-piazza-slack](https://www.npmjs.com/package/hubot-piazza-slack)

Unfurls Piazza post references, like @1234. [See screenshot below.](#screenshot)

See [`src/piazza-slack.coffee`](src/piazza-slack.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-piazza-slack --save`

Then add **hubot-piazza-slack** to your `external-scripts.json`:

```json
[
  "hubot-piazza-slack"
]
```

#### Version sanity checks

Ensure that your server (such as Heroku) has a "reasonable" version of Node.js. An example of a reasonable version is `v5.3.0`. You can check your local version by running `node -v`. If you are using Heroku, you can check your server's version by running `heroku run node -v`. Classic npm installations will not persist via `heroku run npm install...` (they are cloned instances). To update Node.js for your Heroku server, you must edit `package.json` and change the version of node (the default from `hubot-slack` is `0.10.x` which is not acceptable).

```
"engines": {
  "node": "5.3.x"
}
```

## Configuration

You need to set these three environment variables where you run Hubot.

- `HUBOT_PIAZZA_CLASS_ID`: the ID of your Piazza class, found at the end of a piazza URL (e.g. last part of https://piazza.com/class/idmcvkolvsn7p0)
- `HUBOT_PIAZZA_EMAIL`: email to auth with Piazza
- `HUBOT_PIAZZA_PASS`: password to auth with Piazza (plaintext, be wary about who sees this!)

## Sample Interaction

<a name="screenshot"></a>
![yas](example.png)
