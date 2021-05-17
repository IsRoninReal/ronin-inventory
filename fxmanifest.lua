fx_version 'bodacious'
games { 'rdr3', 'gta5' }

version '1.0.0'

ui_page 'nui/ui.html'

files {
	'nui/ui.html',
	'nui/pricedown.ttf',
	'nui/default.png',
	'nui/background.png',
	'nui/invbg.png',
	"nui/weight-hanging-solid.png",
	"nui/hand-holding-solid.png",
	"nui/search-solid.png",
	'nui/styles.css',
	'nui/*.js',
	--'nui/debounce.min.js',
	'nui/loading.gif',
	'nui/loading.svg',
	'nui/icons/*',
}
shared_script 'shared_list.js'
client_script 'client.js'
client_script 'functions.lua'
server_script 'server.js'
server_script 'sv_functions.lua'


exports{
	'hasEnoughOfItem',
	'getQuantity',
	'GetCurrentWeapons',
	'GetItemInfo'
}