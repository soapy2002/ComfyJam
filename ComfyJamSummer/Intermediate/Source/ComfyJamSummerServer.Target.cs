using UnrealBuildTool;

public class ComfyJamSummerServerTarget : TargetRules
{
	public ComfyJamSummerServerTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Server;
		ExtraModuleNames.Add("ComfyJamSummer");
	}
}
