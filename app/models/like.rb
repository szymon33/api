module Like
  def like
    self.like_counter += 1
    save
  end
end
