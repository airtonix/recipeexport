recipeExport = CreateFrame"Frame"
recipeExport:RegisterEvent("TRADE_SKILL_SHOW")
recipeExport.siteUrl = 'http://www.wowhead.com'
recipeExport.recipieUrl = recipeExport.siteUrl..'?spell='
recipeExport.rarity={
 "#9d9d9d",
 "#ffffff",
 "#1eff00",
 "#0070dd",
 "#a335ee",
 "#ff8000",
 "#e6cc80",
 "#e6cc80",
}
recipeExport.template = {
 bbcode = {
   book			= "[b][size=12pt]%s[/size][/b][i]%s/%s[/i]\n",
   header		= "\n[b]%s[/b]\n",
   item			= "[url=%s%s]%s[/url]\n",
   color			= "[color=%s][%s][/color]",
 },
 html = {
   book			= "<h3>%s</h3><i>%s/%s</i>\n",
   header		= "<h4>%s</h4>\n",
   item			= "<a href='%s%s'>%s</a>\n",
   color			= "<span style='font-color:%s;'>%s</span>",
 },
 markdown = {
   book			= "### %s\n\n*%s/%s*\n",
   header		= "#### %s\n\n",
   item			= "[%s](".. recipeExport.recipieUrl .."%s)\n",
   color			= "%s %s",
 },
}

function exportTradeList()
 local txt = recipeExport:renderTradeList(0)
 if not txt then print("No text provided, exiting."); return end
 local window = recipeExport.window
		   window.editor:SetText(txt)
		   window:Show();
		   window.editor:HighlightText()
end

recipeExport:SetScript("OnEvent", function() 
	local event = event:lower()
	if(recipeExport[event])then recipeExport[event]() end
end)

function recipeExport.trade_skill_show()
	--Export Button
	if(not _G['recipeExportViewRunButton'])then 
	exportButton = CreateFrame("Button", "recipeExportViewRunButton", TradeSkillFrame, "OptionsButtonTemplate");
	exportButton:SetText('[export]');
	exportButton:SetWidth("48");
	exportButton:SetNormalTexture(nil)
	exportButton:SetHeight("20");
	exportButton:SetPoint("TOPLEFT", TradeSkillLinkButton, "TOPRIGHT", 2, 1);
	exportButton:SetScript("OnClick", exportTradeList);
	end
end

function recipeExport:renderTradeList(iLevelThreshold)
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
	local item = GetTradeSkillItemLink(i)
	if(item)then
		local _,_,itemString = string.find(item,"^|c%x+|H(.+)|h%[.*%]")
		local itemId = ({strsplit(":", itemString)})[2]
		local itemName, itemLink, itemRarity, iLevel, itemMinLevel, itemType, itemSubType, itemStackCount,itemEquipLoc, itemTexture = GetItemInfo(itemId) 
		local spellId = link:gmatch("enchant:(.*)[[]")();
		local color = tostring(self.rarity[itemRarity and itemRarity+1 or 1])
		 name = format(template.color,color,name)
		 output = output .. format( template.item, self.recipieUrl, spellId, name.." ["..tostring(iLevel).."]")
	end
  end
 end

 return output
end

function recipeExport:CreateOutputWindow()
  local window = CreateFrame("Frame", "recipeExportView", UIParent);
  window:SetPoint("TOP", "UIParent", "TOP");
  window:SetFrameStrata("DIALOG");
  window:SetHeight(600);
  window:SetWidth(800);
  window:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 9, right = 9, top = 9, bottom = 9 }
  });
  window:SetBackdropColor(0, 0, 0, 0.8);
  
  --Close Button
  window.closeButton = CreateFrame("Button", "recipeExportViewCloseButton", window, "OptionsButtonTemplate");
  window.closeButton:SetText('close');
  window.closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -10, -6);
  window.closeButton:SetScript("OnClick", function(this) window:Hide(); end);
  
  --ScrollBar
  window.scrollbar = CreateFrame("ScrollFrame", "recipeExportViewScrollBar", window, "UIPanelScrollFrameTemplate");
  window.scrollbar:SetPoint("TOPLEFT", window, "TOPLEFT", 20, -20);
  window.scrollbar:SetPoint("RIGHT", window, "RIGHT", -30, 0);
  window.scrollbar:SetPoint("BOTTOM", window, "BOTTOM", 0, 20);
  
  --TextArea
  window.editor = CreateFrame("EditBox", "recipeExportViewEditBox",window.scrollbar);
  window.editor:SetFontObject("ChatFontNormal");
  window.editor:SetWidth(750);
  window.editor:SetHeight(85);
  window.editor:SetMultiLine(true);
  window.scrollbar:SetScrollChild(window.editor);
  window.editor:SetScript("OnTextChanged", function(this) window.scrollbar:UpdateScrollChildRect(); end);
  window:Hide();
  self.window = window;
  
end
recipeExport:CreateOutputWindow()


SLASH_TRADESKILL1 = "/tradex";
SLASH_TRADESKILL2 = "/rex";
SlashCmdList["TRADESKILL"] = exportTradeList

