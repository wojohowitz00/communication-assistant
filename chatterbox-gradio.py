import torch
import torchaudio as ta
from chatterbox.tts import ChatterboxTTS
import gradio as gr
import tempfile

# Device setup for Mac
device = "mps" if torch.backends.mps.is_available() else "cpu"
map_location = torch.device(device)

torch_load_original = torch.load
def patched_torch_load(*args, **kwargs):
    if 'map_location' not in kwargs:
        kwargs['map_location'] = map_location
    return torch_load_original(*args, **kwargs)
torch.load = patched_torch_load

# Load model once at startup
model = ChatterboxTTS.from_pretrained(device=device)

def generate_speech(text, audio_prompt, exaggeration, cfg_weight):
    wav = model.generate(
        text,
        audio_prompt_path=audio_prompt,
        exaggeration=exaggeration,
        cfg_weight=cfg_weight
    )
    # Save to temp file
    output_path = tempfile.mktemp(suffix=".wav")
    ta.save(output_path, wav, model.sr)
    return output_path

demo = gr.Interface(
    fn=generate_speech,
    inputs=[
        gr.Textbox(label="Text to speak", lines=3),
        gr.Audio(label="Voice to clone", type="filepath"),
        gr.Slider(0.0, 3.0, value=1.0, label="Exaggeration"),
        gr.Slider(0.0, 1.0, value=0.5, label="CFG Weight"),
    ],
    outputs=gr.Audio(label="Generated Speech"),
    title="Chatterbox Voice Cloning",
)

demo.launch()
