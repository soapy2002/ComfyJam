using UnrealBuildTool;

public class ComfyJamSummerTarget : TargetRules
{
	public ComfyJamSummerTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Game;
		ExtraModuleNames.Add("ComfyJamSummer");
	}
}
