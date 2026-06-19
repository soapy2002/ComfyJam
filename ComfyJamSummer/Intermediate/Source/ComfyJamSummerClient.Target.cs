using UnrealBuildTool;

public class ComfyJamSummerClientTarget : TargetRules
{
	public ComfyJamSummerClientTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Client;
		ExtraModuleNames.Add("ComfyJamSummer");
	}
}
