local json = require("dkjson")


Map = Object:new()
function Map:init()

	local raw = love.filesystem.read("data/map.json")
	local data = json.decode(raw)


	self.tileset = G.newImage("data/tileset.png")
	self.quads = makeQuads(self.tileset:getWidth(), self.tileset:getHeight(), 16)
	self.w = data.width
	self.h = data.height


	self.entities = {}
	self.layers = {}

	for i, layer in pairs(data.layers) do


		if layer.type == "tilelayer" then

			self.layers[layer.name] = layer.data




		elseif layer.name == "entities" then
			for j, obj in ipairs(layer.objects) do


				if obj.name == "player" then
--					entities.player = {
--						x = obj.x + obj.width / 2
--						y = obj.y + obj.height / 2
--					}
				end

			end
		end

	end

end
function Map:draw()

	for y = 0, 30 do
		for x = 0, 30 do

			local cell = self.layers.walls[y * self.w + x + 1]
			if cell > 0 then

				G.draw(self.tileset, self.quads[cell], x * 16, y * 16)

			end


		end
	end
end
