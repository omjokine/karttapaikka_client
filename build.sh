NODE_PATH=tools/node_modules/ coffee tools/coffeescript-concat.coffee src/map.coffee src/lolnas.coffee src/jq_listeners.coffee src/jq_functions.coffee > output.coffee
coffee --compile output.coffee
mv output.js js/application.js
rm output.coffee