xml.instruct!
xml.Response do
    xml.Gather(:action => @postto, :numDigits => 1) do
        xml.Say "Hello this is a call from Twilio.  You have an appointment 
tomorrow at 9 AM."
        xml.Say "Please press 1 to repeat this menu. Press 2 for directions.
Or press 3 if you are done."
    end
end
