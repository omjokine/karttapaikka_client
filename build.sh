mkdir -p js
NODE_PATH=tools/node_modules/ coffee tools/coffeescript-concat.coffee src/tools.coffee src/map.coffee src/lolnas.coffee src/alkot.coffee src/jq_listeners.coffee src/jq_functions.coffee > output.coffee
coffee --compile output.coffee
mv output.js js/application.js
rm output.coffee

# mkdir -p json
# ruby tools/alko/paivita_alkot.rb > json/alkot.json
