-- Refactored `do_sth_with_PlayerParty` and membername to camel case.
function removePlayerPartyMember(playerId, memberName)
  local player = Player(playerId) -- No reason for global scope?
  local party = player:getParty()

  local member = Player(memberName) -- cache party member as there is no need to create new table each time in the loop.
  local members = party:getMembers() -- cached party members as well to be sure that some members would not be skipped because of the removal.
  for _, v in pairs(members) do
    if v == member then
      party:removeMember(member)
    end
  end
end