Then("I should be on the profile page") do
  expect(page).to have_current_path(profile_path)
end
