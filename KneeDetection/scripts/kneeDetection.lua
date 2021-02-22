--[[----------------------------------------------------------------------------

  Application Name:
  KneeDetection

  Summary:
  Detects knees in a profile

  Description:
  Explains how to use the second derivative of a profile to find knees

  How to run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  Restarting the Sample may be necessary to show the profiles after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  on AppStudio 2.3 or higher can be used.

  More Information:
  Tutorial "Algorithms - Profile - FirstSteps".

------------------------------------------------------------------------------]]

--Start of Global Scope---------------------------------------------------------

-------------------------------------------------------------------------------------
-- Helper functins -----------------------------------------------------------------
-------------------------------------------------------------------------------------
local helper = require 'helpers'

-------------------------------------------------------------------------------------
-- Settings -------------------------------------------------------------------------
-------------------------------------------------------------------------------------
local ENABLE_NOISE = true
local SMOOTH_PROFILE = true
local SMOOTHING_KERNEL_SIZE = 9
local DERIVATIVE_KERNEL_SIZE = 45
local EXTREMA_NEIGHBOR_SIZE = 25 -- neighbors to take care of (1 / samples per mm)
local EXTREMA_NEIGHBOR_THRESHOLD = 0.4-- difference to neighbors

local DELAY = 1500 -- For demonstration purpose only

local POLYGON = {
  Point.create(10, 0),
  Point.create(20, 0),
  Point.create(20.1, 25),
  Point.create(30, 25),
  Point.create(35, 40),
  Point.create(51, 31),
  Point.create(57, 18),
  Point.create(58, 0),
  Point.create(70, 0)
}

local LINE_COLOR = {59, 156, 208}
local KNEE_COLOR = {242, 148, 0}
local GREYED_OUT = {230, 230, 230}
local GREYED_OUT_DARKER = {210, 210, 210}

local TEXT_DECO = View.TextDecoration.create()
TEXT_DECO:setSize(3)
TEXT_DECO:setColor(100, 100, 100)

-------------------------------------------------------------------------------------
-- Main functionality ---------------------------------------------------------------
-------------------------------------------------------------------------------------

local function main()
  -------------------------------------
  -- Scan polygon ---------------------
  -------------------------------------

  local polyProfile = helper.polygonToProfile(POLYGON)

  -------------------------------------
  -- Generate random noise ------------
  -------------------------------------

  if ENABLE_NOISE then
    polyProfile = helper.addRandomNoiseToProfile(polyProfile, 0.25)
  end

  -------------------------------------
  -- Smooth profile -------------------
  -------------------------------------

  if SMOOTH_PROFILE then
    polyProfile = polyProfile:gauss(SMOOTHING_KERNEL_SIZE)
  end

  -------------------------------------
  -- Knee detection -------------------
  -------------------------------------

  local secondDerivative = polyProfile:gaussDerivative(DERIVATIVE_KERNEL_SIZE, 'SECOND')
  secondDerivative = secondDerivative:multiplyConstant(100) --amplify derivative

  -- Get maxima indices
  local kneeIndices = secondDerivative:findLocalExtrema('MAX', EXTREMA_NEIGHBOR_SIZE, EXTREMA_NEIGHBOR_THRESHOLD)
  -- Add minima indices
  for _, extrema in pairs(secondDerivative:findLocalExtrema('MIN', EXTREMA_NEIGHBOR_SIZE,EXTREMA_NEIGHBOR_THRESHOLD)) do
    kneeIndices[#kneeIndices + 1] = extrema
  end

  -------------------------------------
  -- Console Output --------------------
  -------------------------------------

  table.sort(kneeIndices)
  local kneePoints = {}
  local kneePointsInDerivative = {}

  for _, index in pairs(kneeIndices) do
    kneePoints[#kneePoints + 1] =
      Point.create(polyProfile:getCoordinate(index), polyProfile:getValue(index))
    kneePointsInDerivative[#kneePointsInDerivative + 1] =
      Point.create(secondDerivative:getCoordinate(index), secondDerivative:getValue(index))
  end

  print('\nNumber of found knees: ' .. #kneePoints .. '\n')
  for i, knee in pairs(kneePoints) do
    print('Knee nr. ' .. i .. ': (' .. knee:getX() .. 'mm, ' .. knee:getY() .. 'mm)')
  end
  print('\nSee viewer on device page for visualization')

  -------------------------------------
  -- Visualization --------------------
  -------------------------------------

  local v = View.create()

  v:clear()
  v:addProfile(polyProfile, helper.graphDeco(LINE_COLOR, 'Scanned profile'))
  v:present()
  Script.sleep(DELAY) -- For demonstration purpose only

  v:clear()
  v:addProfile(polyProfile, helper.graphDeco(GREYED_OUT, 'Second derivative'))
  v:addProfile(secondDerivative, helper.graphDeco(LINE_COLOR, '', true))
  v:present()
  Script.sleep(DELAY) -- For demonstration purpose only

  v:addShape(kneePointsInDerivative, helper.getDeco(KNEE_COLOR))
  v:present()
  Script.sleep(DELAY) -- For demonstration purpose only

  v:clear()
  v:addProfile(secondDerivative, helper.graphDeco(GREYED_OUT, 'Found knees'))
  v:addShape(kneePointsInDerivative, helper.getDeco(GREYED_OUT_DARKER))
  v:addProfile(polyProfile, helper.graphDeco(LINE_COLOR, '', true))
  v:addShape(kneePoints, helper.getDeco(KNEE_COLOR))
  v:present()

  print('App finished.')
end
Script.register('Engine.OnStarted', main)
-- serve API in global scope
