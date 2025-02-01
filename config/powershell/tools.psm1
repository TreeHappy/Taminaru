function Get-RandomEmoticonAndAnimal
{
  # Define the lists of emojis for emotions and animals
  $emotionEmojis = "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😇", "😊", "😋", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "☺️", "🙂", "🤗", "🤩", "🤔", "🤨", "😐", "😑", "😶", "🙄", "😏", "😣", "😥", "😮", "🤐", "😯", "😪", "😫", "😴", "😌", "😛", "😜", "😝", "🤤", "😒", "😓", "😔", "😕", "🙃", "🤑", "😲", "☹️", "🙁", "😖", "😞", "😟", "😤", "😢", "😭", "😦", "😧", "😨", "😩", "🤯", "😬", "😰", "😱", "😳", "🤪", "😵", "😡", "😠"
  $animalEmojis = "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🙈", "🙉", "🙊", "🐒", "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦜", "🐓", "🦃", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐌", "🐛", "🦋", "🐜", "🐝", "🐞", "🦗", "🕷️", "🕸️", "🦂", "🦟", "🦠", "🐘", "🦏", "🦍", "🐪", "🐫", "🦒", "🦓", "🐃", "🐅", "🐎", "🐖", "🐏", "🐑", "🐐", "🦌", "🐕", "🐩", "🐈", "🐓", "🦃", "🕊️", "🐇", "🦝", "🦔", "🦦", "🦥", "🦨", "🦡", "🦫", "🐁", "🐀", "🐿️", "🦔", "🐾"
    
  # Generate a random index for the emotion and animal emojis
  $emotionIndex = Get-Random -Minimum 0 -Maximum ($emotionEmojis.Length)
  $animalIndex = Get-Random -Minimum 0 -Maximum ($animalEmojis.Length)
    
  # Combine the emotion and animal emojis into a string
  $result = $emotionEmojis[$emotionIndex] + $animalEmojis[$animalIndex]
    
  # Return the result
  return $result
}

