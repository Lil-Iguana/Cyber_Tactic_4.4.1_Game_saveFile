# Tutorial steps for BattleSim - Basic Combat Tutorial
# This script creates the tutorial steps as resources
extends Node

static func create_steps() -> Array[TutorialStep]:
	var steps: Array[TutorialStep] = []
	
	# Step 0: Welcome
	var step0 := TutorialStep.new()
	step0.narration_text = "Welcome to combat! Let's learn the basics."
	step0.action_type = TutorialStep.ActionType.NONE
	step0.auto_advance_delay = 2.5
	step0.block_all_except_highlight = true
	steps.append(step0)
	
	# Step 1: Explain Mana
	var step1 := TutorialStep.new()
	step1.narration_text = "This is your Energy. You need energy to play cards."
	step1.highlight_node_path = "BattleUI/ManaUI"
	step1.action_type = TutorialStep.ActionType.NONE
	step1.auto_advance_delay = 3.0
	step1.block_all_except_highlight = true
	steps.append(step1)
	
	# Step 2: Explain Hand
	var step2 := TutorialStep.new()
	step2.narration_text = "These are your cards. Each card costs energy to play."
	step2.highlight_node_path = "BattleUI/Hand"
	step2.action_type = TutorialStep.ActionType.NONE
	step2.auto_advance_delay = 3.0
	step2.block_all_except_highlight = true
	steps.append(step2)
	
	# Step 3: Play an Attack Card
	var step3 := TutorialStep.new()
	step3.narration_text = "Try playing an ATTACK card (red) to damage the enemy!"
	step3.highlight_node_path = "BattleUI/Hand"
	step3.action_type = TutorialStep.ActionType.PLAY_CARD_TYPE
	step3.card_type_required = Card.Type.ATTACK
	step3.block_all_except_highlight = false  # Allow card interactions!
	steps.append(step3)
	
	# Step 4: Explain Enemy Intent
	var step4 := TutorialStep.new()
	step4.narration_text = "Look at the enemy's intent icon. It shows what they'll do next turn!"
	step4.highlight_node_path = "EnemyHandler/MalwareEnemy/IntentUI"
	step4.action_type = TutorialStep.ActionType.NONE
	step4.auto_advance_delay = 3.5
	step4.block_all_except_highlight = true
	steps.append(step4)
	
	# Step 5: Play a Skill Card
	var step5 := TutorialStep.new()
	step5.narration_text = "Now try a SKILL card (blue) to defend yourself!"
	step5.highlight_node_path = "BattleUI/Hand"
	step5.action_type = TutorialStep.ActionType.PLAY_CARD_TYPE
	step5.card_type_required = Card.Type.SKILL
	step5.block_all_except_highlight = false
	steps.append(step5)
	
	# Step 6: Explain Block
	var step6 := TutorialStep.new()
	step6.narration_text = "Block (shield icon) protects you from damage until your next turn."
	step6.highlight_node_path = "Player/StatsUI"
	step6.action_type = TutorialStep.ActionType.NONE
	step6.auto_advance_delay = 3.0
	step6.block_all_except_highlight = true
	steps.append(step6)
	
	# Step 7: End Turn
	var step7 := TutorialStep.new()
	step7.narration_text = "When you're done playing cards, press END TURN to let enemies act."
	step7.highlight_node_path = "BattleUI/EndTurnButton"
	step7.action_type = TutorialStep.ActionType.END_TURN
	step7.block_all_except_highlight = false  # Allow clicking end turn
	steps.append(step7)
	
	# Step 8: Watch Enemy Turn
	var step8 := TutorialStep.new()
	step8.narration_text = "Watch the enemy perform their action based on their intent!"
	step8.action_type = TutorialStep.ActionType.WAIT_ENEMY_TURN
	step8.block_all_except_highlight = true
	steps.append(step8)
	
	# Step 9: New Turn Explanation
	var step9 := TutorialStep.new()
	step9.narration_text = "Your energy refills each turn, and you draw new cards!"
	step9.highlight_node_path = "BattleUI/ManaUI"
	step9.action_type = TutorialStep.ActionType.NONE
	step9.auto_advance_delay = 3.0
	step9.block_all_except_highlight = true
	steps.append(step9)
	
	# Step 10: Card Types Reminder
	var step10 := TutorialStep.new()
	step10.narration_text = "Remember: Red cards ATTACK, Blue cards provide SKILLS like blocking!"
	step10.action_type = TutorialStep.ActionType.NONE
	step10.auto_advance_delay = 3.5
	step10.block_all_except_highlight = true
	steps.append(step10)
	
	# Step 11: Final
	var step11 := TutorialStep.new()
	step11.narration_text = "Great job! Now defeat this enemy to complete the tutorial!"
	step11.action_type = TutorialStep.ActionType.NONE
	step11.auto_advance_delay = 3.0
	step11.block_all_except_highlight = false
	steps.append(step11)
	
	return steps
