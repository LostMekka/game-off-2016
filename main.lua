G = love.graphics


-- init technical stuff
W = 320
H = 200
G.setDefaultFilter("nearest", "nearest")
canvas = G.newCanvas(W, H)
love.window.setMode(W * 2, H * 2, {resizable = true})
love.mouse.setVisible(false)


require("helper")
require("map")



map = Map()








function love.update(dt)



end

t = 0

function love.draw()
	G.setCanvas(canvas)
	G.clear(0, 0, 0)


	-- render stuff

	t = t + 1


--	G.translate(400, 300)
	G.rotate(math.sin(t*0.1) * 0.2)


	map:draw()





	-- draw canvas independent of resolution
	local w = G.getWidth()
	local h = G.getHeight()
	G.origin()
	if w / h < W / H then
		G.translate(0, (h - w / W * H) * 0.5)
		G.scale(w / W, w / W)
	else
		G.translate((w - h / H * W) * 0.5, 0)
		G.scale(h / H, h / H)
	end
	G.setCanvas()
	G.draw(canvas)
end
