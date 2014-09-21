
void main()
{
    vec4 color = texture2D(u_texture, v_tex_coord.st);
    
    //ugly way to change blue to red :D
    if(color.b > 0.3 && color.r < 0.3) {
        float tmp = color.b;
        color.b = color.r;
        color.r = tmp;
    }

    gl_FragColor = color;
}
