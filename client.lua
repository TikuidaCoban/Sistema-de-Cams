local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
Tiku = Tunnel.getInterface("Tikuida_Cameras")

inCam = false
CAM = 0

Cameras = {
	[1] =  { ['x'] = 92.17,['y'] = -1923.14,['z'] = 29.5,['h'] = 205.95 },
	[2] =  { ['x'] = -176.26,['y'] = -1681.15,['z'] = 47.43,['h'] = 313.29 },
	[3] =  { ['x'] = 285.95,['y'] = -2003.95,['z'] = 35.0,['h'] = 226.0 }
}

RegisterCommand("cam", function (source, args)
	local cam = args[1]
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	local bowz,cdz = GetGroundZFor_3dCoord(x,y,z)
	local distance = GetDistanceBetweenCoords(x,y,cdz,445.6745300293,-983.63153076172,30.685089111328)
	if distance < 40 and Tiku.checkPermission() then
		TriggerEvent('camera', cam)
	end
end) 


RegisterNetEvent("camera")
AddEventHandler("camera", function(camNumber)
	camNumber = tonumber(camNumber)
	if inCam then
		inCam = false
		PlaySoundFrontend(-1, "HACKING_SUCCESS", false)
		TriggerEvent('animation:tablet',true)
		Wait(250)
		ClearPedTasks(GetPlayerPed(-1))
	else
		if camNumber > 0 and camNumber < #Cameras+1 then
			PlaySoundFrontend(-1, "HACKING_SUCCESS", false)
			TriggerEvent("StartCamera",camNumber)
		end
	end
end)

RegisterNetEvent("StartCamera")
AddEventHandler("StartCamera", function(camNumber)

	TriggerEvent('animation:tablet',true)
	local camNumber = tonumber(camNumber)
	local x = Cameras[camNumber]["x"]
	local y = Cameras[camNumber]["y"]
	local z = Cameras[camNumber]["z"]
	local h = Cameras[camNumber]["h"]

	inCam = true

	SetTimecycleModifier("heliGunCam")
	SetTimecycleModifierStrength(1.0)
	local scaleform = RequestScaleformMovie("TRAFFIC_CAM")
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end

	local lPed = GetPlayerPed(-1)
	CAM = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamCoord(CAM,x,y,z+1.2)						
	SetCamRot(CAM, -15.0,0.0,h)
	SetCamFov(CAM, 110.0)
	RenderScriptCams(true, false, 0, 1, 0)
	PushScaleformMovieFunction(scaleform, "PLAY_CAM_MOVIE")
	SetFocusArea(x, y, z, 0.0, 0.0, 0.0)
	PopScaleformMovieFunctionVoid()

	while inCam do
		SetCamCoord(CAM,x,y,z+1.2)						
		SetCamRot(CAM, -15.0,0.0,h)
		PushScaleformMovieFunction(scaleform, "SET_ALT_FOV_HEADING")
		PushScaleformMovieFunctionParameterFloat(GetEntityCoords(h).z)
		PushScaleformMovieFunctionParameterFloat(1.0)
		PushScaleformMovieFunctionParameterFloat(GetCamRot(CAM, 2).z)
		PopScaleformMovieFunctionVoid()
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		Citizen.Wait(1)
	end
	ClearFocus()
	ClearTimecycleModifier()
	RenderScriptCams(false, false, 0, 1, 0)
	SetScaleformMovieAsNoLongerNeeded(scaleform)
	DestroyCam(CAM, false)
	SetNightvision(false)
	SetSeethrough(false)	

end)

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		if inCam then
			local rota = GetCamRot(CAM, 2) 
			if IsControlPressed(1, 108) then
				SetCamRot(CAM, rota.x, 0.0, rota.z + 0.7, 2)
			end
			if IsControlPressed(1, 107) then
				SetCamRot(CAM, rota.x, 0.0, rota.z - 0.7, 2)
			end
			if IsControlPressed(1,  61) then
				SetCamRot(CAM, rota.x + 0.7, 0.0, rota.z, 2)
			end
			if IsControlPressed(1, 60) then
				SetCamRot(CAM, rota.x - 0.7, 0.0, rota.z, 2)
			end
		end
	end
end)