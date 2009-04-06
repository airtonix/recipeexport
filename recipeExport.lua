recipeExport = CreateFrame"Frame"
recipeExport.profName = GetTradeSkillLine()
recipeExport.sitseUrl = 'http://www.wowhead.com'
recipeExport.recipieUrl = recipeExport.siteUrl..'?spell='
recipeExport.template = {
 bbcode = {
   header		= "[b]%s[/b]\n",
   item			= "[url=%s%s]%s[/url]\n",
   book			= "[b][size=12pt]%s[/size][/b][i]%s/%s[/i]\n"
 }
}

function recipeExport:renderTradeList()
 local tradeSkillsNum, name, type
 local template = self.template['bbcode']
 local tradeSkillName, currentLevel, maxLevel = GetTradeSkillLine();
 if(tradeSkillName =="UNKNOWN")then print("Tradeskill Window Not Open.");return end
 
 local output = format(template.book,tradeSkillName,currentLevel,maxLevel)

 for i=1,GetNumTradeSkills() do
  local name, type, _, _, _ = GetTradeSkillInfo(i);
  if (name and type == "header") then
   output = output .. format(template.header, name)
  else
   local link = GetTradeSkillRecipeLink(i)
   local spellId = link:gmatch("enchant:(.*)[[]")();
   output = output .. format( template.item, self.recipieUrl, spellId, name)
  end
 end

 return output
end

function recipeExport:createTextArea(txt)
 if not txt then print("No text provided exiting."); return end
 if self.report == nil then
  self.report=CreateFrame("Frame", "recipeExportView", UIParent);
 end
 
 local report = self.report
  report:Hide(); 
  report:SetPoint("CENTER", "UIParent", "CENTER");
  report:SetFrameStrata("DIALOG");
  report:SetHeight(600);
  report:SetWidth(800);
  report:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 9, right = 9, top = 9, bottom = 9 }
 });
  report:SetBackdropColor(0, 0, 0, 0.8);
  
  --Close Button
  report.DoneButton = CreateFrame("Button", "recipeExportViewCloseButton", report, "OptionsButtonTemplate");
  report.DoneButton:SetText('close');
  report.DoneButton:SetPoint("BOTTOMRIGHT", report, "BOTTOMRIGHT", -10, 10);
  report.DoneButton:SetScript("OnClick", function(this)
  	report:Hide();
  end);
  
  --ScrollBar
  report.Scroll = CreateFrame("ScrollFrame", "recipeExportViewScrollFrame", report, "UIPanelScrollFrameTemplate");
  report.Scroll:SetPoint("TOPLEFT", report, "TOPLEFT", 20, -20);
  report.Scroll:SetPoint("RIGHT", report, "RIGHT", -30, 0);
  report.Scroll:SetPoint("BOTTOM", report.DoneButton, "TOP", 0, 20);
  
  --TextArea
  report.Box = CreateFrame("EditBox", "recipeExportViewEditBox", report.Scroll);
  report.Box:SetWidth(750);
  report.Box:SetHeight(85);
  report.Box:SetFontObject("ChatFontNormal");
  report.Box:SetMultiLine(true);
  report.Scroll:SetScrollChild(report.Box);
  report.Box:SetText(txt);
  report.Box:HighlightText();  
  report.Box:SetScript("OnTextChanged", function(this)
    report.Scroll:UpdateScrollChildRect();
  end);
  report:Show();
  report.Box:HighlightText();  
end

SLASH_TRADESKILL1 = "/recipeExport";
SLASH_TRADESKILL2 = "/rex";
SlashCmdList["TRADESKILL"] = function()
 local txt = recipeExport:renderTradeList()
 if(txt)then recipeExport:createTextArea(txt) end
end;

