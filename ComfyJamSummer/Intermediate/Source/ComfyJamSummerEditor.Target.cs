using UnrealBuildTool;

public class ComfyJamSummerEditorTarget : TargetRules
{
	public ComfyJamSummerEditorTarget(TargetInfo Target) : base(Target)
	{
		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		Type = TargetType.Editor;
		ExtraModuleNames.Add("ComfyJamSummer");
	}
}
