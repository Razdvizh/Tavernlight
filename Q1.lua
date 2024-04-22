-- Assuming that the logic should release storage only if its value equals 1.
function onLogout(player)
  if player:getStorageValue(1000) == 1 then
    player:setStorageValue(1000, -1) -- player will be invalid after logout, so release storage right before event finishes.
  end
  return true
end

-- What is the reason for the delay anyway? If there is a reason, delay should be handled differently,
-- perhaps by changing saved data instead of the runtime one.
