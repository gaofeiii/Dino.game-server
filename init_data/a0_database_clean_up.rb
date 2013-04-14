puts "[Clean up] Clean up Database..."
Dinosaur.delete_attrs :growth_point
Player.delete_attrs :is_advisor, :is_hired, :advisor_type