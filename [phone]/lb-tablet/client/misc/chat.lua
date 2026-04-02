RegisterNetEvent("tablet:chat:setIcon", function(id, avatar)
  SendReactMessage("chat:setChatAvatar", { id = id, avatar = avatar })
end)

RegisterNetEvent("tablet:chat:joinRoom", function(room)
  SendReactMessage("chat:joinChatRoom", room)
end)

RegisterNetEvent("tablet:chat:leaveRoom", function(room)
  SendReactMessage("chat:leaveChatRoom", room)
end)

RegisterNetEvent("tablet:chat:newMessage", function(message)
  SendReactMessage("chat:newMessage", message)
end)

RegisterNetEvent("tablet:chat:setPrivate", function(id, isPrivate)
  SendReactMessage("chat:setPrivate", { id = id, private = isPrivate })
end)