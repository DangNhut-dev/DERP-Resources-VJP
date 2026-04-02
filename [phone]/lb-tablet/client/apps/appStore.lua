ReactCallback("AppStore", function(A0_2)
  if A0_2.action == "buyApp" then
    return AwaitCallback("appStore:buyApp", A0_2.price)
  end
end)